import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RasdLoginResult {
  final String uid;
  final String role;

  const RasdLoginResult({required this.uid, required this.role});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Internal Firebase login identifier.
  // The user enters only their National ID.
  String _internalEmail(String nationalId) {
    if (!RegExp(r'^[0-9]{10}$').hasMatch(nationalId)) {
      throw const FormatException('National ID must contain exactly 10 digits');
    }

    return '$nationalId@rasd.invalid';
  }

  Future<RasdLoginResult> login({
    required String nationalId,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: _internalEmail(nationalId),
      password: password,
    );

    final uid = credential.user!.uid;

    try {
      // Check whether this user is an employee.
      final employee = await _db.collection('employees').doc(uid).get();

      if (employee.exists) {
        final data = employee.data()!;

        if (data['nationalId'] != nationalId ||
            data['role'] != 'employee' ||
            data['accountStatus'] != 'active') {
          throw StateError('Employee account is not active');
        }

        return RasdLoginResult(uid: uid, role: 'employee');
      }

      // Otherwise check citizen accounts.
      final citizen = await _db.collection('citizens').doc(uid).get();

      if (citizen.exists) {
        final data = citizen.data()!;

        if (data['nationalId'] != nationalId ||
            data['role'] != 'citizen' ||
            data['accountStatus'] != 'active') {
          throw StateError('Citizen account is not active');
        }

        return RasdLoginResult(uid: uid, role: 'citizen');
      }

      throw StateError('RASD account not found');
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
