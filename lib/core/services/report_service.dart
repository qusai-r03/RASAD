import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  Future<String> submitReport({
    required XFile image,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw const FormatException('يرجى تسجيل الدخول مجدداً');
    if (await image.length() > 5 * 1024 * 1024) {
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
        defaultValue: 'http://127.0.0.1:8000');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/reports/'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll({
        'category': category,
        'description': description,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      })
      ..files.add(http.MultipartFile.fromBytes('image', await image.readAsBytes(),
          filename: image.name, contentType: MediaType.parse(type)));
    final response = await http.Response.fromStream(await request.send());
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

  Future<ReportModel?> getReportById(String reportId) async {
    final document = await _reportsCollection.doc(reportId).get();

    if (!document.exists) {
      return null;
    }

    return ReportModel.fromFirestore(document);
  }

  Future<List<ReportModel>> getCitizenReports(String citizenId) async {
    final snapshot = await _reportsCollection
        .where('citizenId', isEqualTo: citizenId)
        .get();

    return snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();
  }

  Future<List<ReportModel>> getEmployeeReports(String municipalityId) async {
    final snapshot = await _reportsCollection
        .where('municipalityId', isEqualTo: municipalityId)
        .get();

    return snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();
  }

  Future<String> getEmployeeMunicipalityId(String employeeUid) async {
    final document = await _firestore
        .collection('employees')
        .doc(employeeUid)
        .get();

    if (!document.exists) {
      throw StateError('Employee profile not found.');
    }

    final municipalityId = document.data()?['municipalityId'];

    if (municipalityId is! String || municipalityId.trim().isEmpty) {
      throw StateError('Employee municipality is missing.');
    }

    return municipalityId;
  }

  Future<void> updateReportPriority({
    required String reportId,
    required String priority,
  }) async {
    const allowedPriorities = {'low', 'medium', 'high'};

    if (!allowedPriorities.contains(priority)) {
      throw ArgumentError('Invalid report priority.');
    }

    await _reportsCollection.doc(reportId).update({'priority': priority});
  }
}
