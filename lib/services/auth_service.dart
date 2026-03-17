import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// =========================
  /// GOOGLE SIGN-IN
  /// =========================
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Google sign-in error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Unexpected Google sign-in error: $e');
      rethrow;
    }
  }

  /// =========================
  /// EMAIL REGISTER
  /// =========================
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.code}');
      rethrow;
    }
  }

  /// =========================
  /// EMAIL LOGIN
  /// =========================
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code}');
      rethrow;
    }
  }

  /// =========================
  /// SIGN OUT
  /// =========================
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // ensures Google session clears too
  }

  /// =========================
  /// CURRENT USER
  /// =========================
  User? get currentUser => _auth.currentUser;
}
