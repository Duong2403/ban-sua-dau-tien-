// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '303885748047-n6atrsmshpqr8qgvf1v3gn38o44j1raq.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In Process...');

      late final GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Web platform
        googleUser = await _googleSignIn.signInSilently() ??
            await _googleSignIn.signIn();
      } else {
        // Mobile platforms
        googleUser = await _googleSignIn.signIn();
      }

      print('Google Sign In Result: ${googleUser?.email}');

      if (googleUser == null) {
        print('Google Sign In Cancelled by User');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Obtained Google Auth Tokens');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase Auth Completed: ${userCredential.user?.email}');

      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  // Other methods remain the same...
}
