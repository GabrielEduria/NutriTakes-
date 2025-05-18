import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen to auth changes (sign-in, sign-out)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        await _firebaseAuth.signOut();
        throw Exception('Please verify your email before logging in.');
      }

      return cred.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
     Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Could not send password reset email: $e');
    }
  }
  
  // Register with email and password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await cred.user!.sendEmailVerification();

      return cred.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Send email verification again
  Future<void> resendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else {
      throw Exception('User not found or already verified.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
