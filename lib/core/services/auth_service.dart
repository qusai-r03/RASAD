import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the currently authenticated user.
  User? get currentUser => _auth.currentUser;

  // Listen for login and logout changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Basic Firebase password login.
  // The final RASD login will use usernames instead.
  Future<UserCredential> signInWithInternalEmail({
    required String internalEmail,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: internalEmail,
      password: password,
    );
  }

  // Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
