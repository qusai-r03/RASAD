import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<UserCredential> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid username or password');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['customToken'] as String;

    return FirebaseAuth.instance.signInWithCustomToken(token);
  }
}