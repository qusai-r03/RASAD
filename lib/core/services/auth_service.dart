import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Complete Firebase sign-in using a token issued
  // by RASD's trusted username/password backend.
  Future<UserCredential> signInWithCustomToken({required String token}) async {
    return _auth.signInWithCustomToken(token);
  }

  // Read the role assigned by the trusted backend.
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final idToken = await user.getIdTokenResult(true);

    return idToken.claims?['role'] as String?;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
