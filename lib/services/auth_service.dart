import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Đăng nhập với Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      late final GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        googleUser = await _googleSignIn.signInSilently() ??
            await _googleSignIn.signIn();
      } else {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createOrUpdateUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  Future<void> _createOrUpdateUser(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    try {
      final profileData = {
        'email': user.email,
        'name': user.displayName ?? '',
        'phone': '',
        'unit': '',
        'room': '',
        'squadron': '',
        'class': '',
        'major': '',
        'lastLogin': FieldValue.serverTimestamp(),
      };

      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          ...profileData,
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email,
        });
      }
    } catch (e) {
      print('Lỗi: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Lỗi: $e');
      return null;
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Lỗi: $e');
      rethrow;
    }
  }

  Future<bool> isAdmin() async {
    return _auth.currentUser?.email == 'anhduongxx2403@gmail.com';
  }
}
