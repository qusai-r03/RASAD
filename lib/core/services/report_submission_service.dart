import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ReportSubmissionService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  Future<String> submitReport({
    required XFile image,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
  }) async {
    // 1. Check Backend URL.
    if (_baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured.');
    }

    // 2. Check Firebase Authentication.
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'You must log in before submitting a report.',
      );
    }

    // 3. Get Firebase ID Token.
    final token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Unable to get Firebase authentication token.',
      );
    }

    // 4. Prepare Backend URL.
    final uri = Uri.parse(
      '${_baseUrl.replaceAll(RegExp(r"/+$"), "")}/reports/',
    );

    // 5. Create Multipart Request.
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // 6. Add Report Information.
    request.fields['category'] = category;
    request.fields['description'] = description;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    // 7. Read Image.
    final imageBytes = await image.readAsBytes();

    if (imageBytes.isEmpty) {
      throw Exception('Image cannot be empty.');
    }

    if (imageBytes.length > 5 * 1024 * 1024) {
      throw Exception('Image must be smaller than 5 MB.');
    }

    // 8. Validate Image Extension.
    final filename = image.name;
    final extension = filename.split('.').last.toLowerCase();

    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw Exception(
          'Only JPG, PNG and WebP images are supported.',
        ),
    };

    // 9. Attach Image.
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    // 10. Send Report to Backend.
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    // 11. Decode Server Response.
    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Invalid server response: ${response.statusCode}',
      );
    }

    // 12. Handle Server Errors.
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        data['detail']?.toString() ??
            'Failed to submit report.',
      );
    }

    // 13. Verify Successful Submission.
    if (data['success'] != true ||
        data['reportId'] is! String) {
      throw Exception(
        'The server did not confirm report creation.',
      );
    }

    // 14. Return New Report ID.
    return data['reportId'] as String;
  }
}