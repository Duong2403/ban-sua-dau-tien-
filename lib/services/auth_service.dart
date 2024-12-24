// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state stream
  Stream<User?> get authStateChanges {
    print('Auth state stream initialized');
    return _auth.authStateChanges();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In Process...');

      // Begin sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google Sign In Result: ${googleUser?.email}');

      if (googleUser == null) {
        print('Google Sign In Cancelled by User');
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Obtained Google Auth Tokens');

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase Auth Completed: ${userCredential.user?.email}');

      // Create/Update user document
      await _createOrUpdateUser(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  // Create or update user document
  Future<void> _createOrUpdateUser(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    try {
      final userData = {
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      };

      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Create new user
        await userDoc.set({
          ...userData,
          'role': 'student', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Created new user document');
      } else {
        // Update existing user
        await userDoc.update(userData);
        print('Updated user document');
      }
    } catch (e) {
      print('Error in _createOrUpdateUser: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Starting Sign Out Process...');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Sign Out Complete');
    } catch (e) {
      print('Error in signOut: $e');
      rethrow;
    }
  }
}
