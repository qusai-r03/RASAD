import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ReportSubmissionService {
  Future<String> submitReport({
    required XFile image,
    required String category,
    required String predictedCategory,
    double? accuracyMeters,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null || token.isEmpty) throw const FormatException('يرجى تسجيل الدخول مجدداً');
    final length = await image.length();
    if (length == 0) throw const FormatException('الصورة فارغة');
    if (length > 5 * 1024 * 1024) {
      throw const FormatException('يجب ألا يتجاوز حجم الصورة 5 ميغابايت');
    }
    final type = image.mimeType ?? switch (image.name.split('.').last.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => '',
    };
    if (!{'image/jpeg', 'image/png', 'image/webp'}.contains(type)) {
      throw const FormatException('اختَر صورة JPG أو PNG أو WebP');
    }
    const baseUrl = String.fromEnvironment('RASD_API_URL',
        defaultValue: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000'));
    final endpoint = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final request = http.MultipartRequest('POST', Uri.parse('$endpoint/reports/'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll({
        'category': category,
        'aiPredictedCategory': predictedCategory,
        if (accuracyMeters != null && accuracyMeters.isFinite && accuracyMeters >= 0)
          'gpsAccuracyMeters': accuracyMeters.toString(),
        'description': description,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      })
      ..files.add(http.MultipartFile.fromBytes('image', await image.readAsBytes(),
          filename: image.name, contentType: MediaType.parse(type)));
    final response = await http.Response.fromStream(await request.send().timeout(const Duration(seconds: 60)));
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode ~/ 100 != 2) {
      final detail = body is Map ? body['detail'] : null;
      throw FormatException(detail is String ? detail : 'تعذر إرسال البلاغ');
    }
    if (body is! Map || body['success'] != true || body['reportId'] is! String) {
      throw const FormatException('تعذر تأكيد الإرسال. تحقق من شكاواي');
    }
    return body['reportId'] as String;
  }
}
