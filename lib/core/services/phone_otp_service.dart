import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PhoneOtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;

  String normalizePhoneNumber(String phone) {
    final normalized = phone.trim().replaceAll(RegExp(r'[\s-]'), '');

    if (RegExp(r'^\+9627[789]\d{7}$').hasMatch(normalized)) {
      return normalized;
    }

    if (RegExp(r'^07[789]\d{7}$').hasMatch(normalized)) {
      return '+962${normalized.substring(1)}';
    }

    throw const FormatException('Invalid Jordanian phone number');
  }

  Future<bool> sendOtp(String phoneNumber) async {
    final completer = Completer<bool>();
    final formattedPhone = normalizePhoneNumber(phoneNumber);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('OTP: Automatic verification callback');

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },

        verificationFailed: (FirebaseAuthException error) {
          debugPrint('OTP FAILED: ${error.code} - ${error.message}');

          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;

          debugPrint('OTP: Code sent successfully');

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );
    } catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    return completer.future;
  }

  Future<bool> resendOtp(String phoneNumber) async {
    final completer = Completer<bool>();
    final formattedPhone = normalizePhoneNumber(phoneNumber);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) {
          debugPrint('OTP: Automatic verification callback');
        },

        verificationFailed: (FirebaseAuthException error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );
    } catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    return completer.future;
  }

  PhoneAuthCredential createCredential(String code) {
    final verificationId = _verificationId;

    if (verificationId == null) {
      throw StateError('No phone verification session exists');
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const FormatException('OTP must contain exactly 6 digits');
    }

    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
  }

  Future<void> verifyAndRegister({
    required String code,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String nationalId,
    required String phoneNumber,
    required String password,
  }) async {
    final formattedPhone = normalizePhoneNumber(phoneNumber);

    debugPrint('REGISTRATION: Verifying phone credential');

    final phoneCredential = createCredential(code);

    // Firebase validates the SMS code.
    final phoneResult = await _auth.signInWithCredential(phoneCredential);

    final user = phoneResult.user;

    if (user == null) {
      throw StateError('Firebase phone authentication failed');
    }

    debugPrint('REGISTRATION: Phone verified');

    if (user.phoneNumber != formattedPhone) {
      throw StateError('Verified phone number mismatch');
    }

    final internalEmail = '$nationalId@rasd.invalid';

    // Link National ID/password login to the same Firebase UID.
    if (user.email != internalEmail) {
      final emailCredential = EmailAuthProvider.credential(
        email: internalEmail,
        password: password,
      );

      await user.linkWithCredential(emailCredential);
    }

    debugPrint('REGISTRATION: Password credential linked');

    // Obtain the Firebase token for backend verification.
    final idToken = await user.getIdToken(true);

    if (idToken == null) {
      throw StateError('Could not obtain Firebase ID token');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/auth/complete-citizen'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'nationalId': nationalId,
        'phoneNumber': formattedPhone,
      }),
    );

    debugPrint(
      'REGISTRATION: Backend status ${response.statusCode}',
    );

    if (response.statusCode != 200) {
      debugPrint('REGISTRATION: Backend response ${response.body}');

      throw StateError(
        'Registration failed (${response.statusCode}): ${response.body}',
      );
    }

    debugPrint('REGISTRATION: Citizen created successfully');

    // Require the user to log in normally after registration.
    await _auth.signOut();
  }
}