import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Passes methods
  Stream<QuerySnapshot> getPassesStream() {
    return _firestore
        .collection('passes')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  Future<void> createPass(Map<String, dynamic> passData) async {
    await _firestore.collection('passes').add({
      ...passData,
      'userId': _auth.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Excusals methods
  Stream<QuerySnapshot> getExcusalsStream() {
    return _firestore
        .collection('excusals')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  Future<void> createExcusal(Map<String, dynamic> excusalData) async {
    await _firestore.collection('excusals').add({
      ...excusalData,
      'userId': _auth.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Metrics methods
  Stream<QuerySnapshot> getMetricsStream() {
    return _firestore
        .collection('metrics')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Profile methods
  Stream<DocumentSnapshot> getUserProfile() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .snapshots();
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .update(profileData);
  }
}