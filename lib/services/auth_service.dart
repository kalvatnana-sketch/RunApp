import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    // #region agent log
    try {
      final logFile = File(
        '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-4c93f5.log',
      );
      final logEntry = jsonEncode({
        'sessionId': '4c93f5',
        'runId': 'initial',
        'hypothesisId': 'H-entry',
        'location': 'auth_service.dart:signInWithGoogle',
        'message': 'signInWithGoogle called',
        'data': {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
    } catch (_) {
      // ignore logging errors
    }
    // #endregion

    try {
      // Start the Google sign-in flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // #region agent log
        try {
          final logFile = File(
            '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-4c93f5.log',
          );
          final logEntry = jsonEncode({
            'sessionId': '4c93f5',
            'runId': 'initial',
            'hypothesisId': 'H-cancelled',
            'location': 'auth_service.dart:signInWithGoogle',
            'message': 'User cancelled Google sign-in',
            'data': {},
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
        } catch (_) {
          // ignore logging errors
        }
        // #endregion
        throw Exception('Sign-in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final result = await _auth.signInWithCredential(credential);

      // #region agent log
      try {
        final logFile = File(
          '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-4c93f5.log',
        );
        final logEntry = jsonEncode({
          'sessionId': '4c93f5',
          'runId': 'initial',
          'hypothesisId': 'H-success',
          'location': 'auth_service.dart:signInWithGoogle',
          'message': 'Firebase sign-in succeeded',
          'data': {'userUid': result.user?.uid},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
      } catch (_) {
        // ignore logging errors
      }
      // #endregion

      return result;
    } catch (e) {
      print('Agent H-error in signInWithGoogle: $e');
      // #region agent log
      try {
        final logFile = File(
          '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-4c93f5.log',
        );
        final logEntry = jsonEncode({
          'sessionId': '4c93f5',
          'runId': 'initial',
          'hypothesisId': 'H-error',
          'location': 'auth_service.dart:signInWithGoogle',
          'message': 'Error during Google/Firebase sign-in',
          'data': {'error': e.toString()},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
      } catch (_) {
        // ignore logging errors
      }
      // #endregion

      rethrow;
    }
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    // #region agent log
    try {
      final logFile = File(
        '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-1cfd71.log',
      );
      final logEntry = jsonEncode({
        'sessionId': '1cfd71',
        'runId': 'initial',
        'hypothesisId': 'H-register-entry',
        'location': 'auth_service.dart:registerWithEmail',
        'message': 'registerWithEmail called',
        'data': {'email': email},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
    } catch (_) {
      // ignore logging errors
    }
    // #endregion

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // #region agent log
      try {
        final logFile = File(
          '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-1cfd71.log',
        );
        final logEntry = jsonEncode({
          'sessionId': '1cfd71',
          'runId': 'initial',
          'hypothesisId': 'H-register-success',
          'location': 'auth_service.dart:registerWithEmail',
          'message': 'Email registration succeeded',
          'data': {'userUid': result.user?.uid},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
      } catch (_) {
        // ignore logging errors
      }
      // #endregion

      return result;
    } catch (e) {
      // #region agent log
      try {
        final logFile = File(
          '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-1cfd71.log',
        );
        final logEntry = jsonEncode({
          'sessionId': '1cfd71',
          'runId': 'initial',
          'hypothesisId': 'H-register-error',
          'location': 'auth_service.dart:registerWithEmail',
          'message': 'Error during email registration',
          'data': {'error': e.toString()},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
      } catch (_) {
        // ignore logging errors
      }
      // #endregion

      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    // #region agent log
    try {
      final logFile = File(
        '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-1cfd71.log',
      );
      final logEntry = jsonEncode({
        'sessionId': '1cfd71',
        'runId': 'initial',
        'hypothesisId': 'H-login-entry',
        'location': 'auth_service.dart:signInWithEmail',
        'message': 'signInWithEmail called',
        'data': {'email': email},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
    } catch (_) {
      // ignore logging errors
    }
    // #endregion

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // #region agent log
      try {
        final logFile = File(
          '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-1cfd71.log',
        );
        final logEntry = jsonEncode({
          'sessionId': '1cfd71',
          'runId': 'initial',
          'hypothesisId': 'H-login-success',
          'location': 'auth_service.dart:signInWithEmail',
          'message': 'Email login succeeded',
          'data': {'userUid': result.user?.uid},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
      } catch (_) {
        // ignore logging errors
      }
      // #endregion

      return result;
    } catch (e) {
      // #region agent log
      try {
        final logFile = File(
          '/Users/anastasiakalvatn/Documents/notracerun_app/.cursor/debug-1cfd71.log',
        );
        final logEntry = jsonEncode({
          'sessionId': '1cfd71',
          'runId': 'initial',
          'hypothesisId': 'H-login-error',
          'location': 'auth_service.dart:signInWithEmail',
          'message': 'Error during email login',
          'data': {'error': e.toString()},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append);
      } catch (_) {
        // ignore logging errors
      }
      // #endregion

      rethrow;
    }
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
