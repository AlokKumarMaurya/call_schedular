import 'package:call_schedular/services/app_crash_reporter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppAuthService {
  AppAuthService._();

  static final AppAuthService instance = AppAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleSignInInitialized = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleSignInInitialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      final googleUser = await _googleSignIn.authenticate();

      final googleAuthentication = googleUser.authentication;

      final idToken = googleAuthentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google Sign-In did not return an ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        await AppCrashReporter.instance.setUserIdentifier(user.uid);

        AppCrashReporter.instance.log(
          'User signed in with Google',
        );
      }

      return userCredential;
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Google Sign-In failed',
      );

      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();

      if (_googleSignInInitialized) {
        await _googleSignIn.signOut();
      }

      await AppCrashReporter.instance.clearUserIdentifier();

      AppCrashReporter.instance.log(
        'User signed out',
      );
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Google Sign-Out failed',
      );

      rethrow;
    }
  }
}
