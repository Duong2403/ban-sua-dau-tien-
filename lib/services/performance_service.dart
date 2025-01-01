// lib/services/performance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance.dart';

class PerformanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPerformance(Performance performance) async {
    await _firestore.collection('performances').add(performance.toMap());
  }

  Future<void> updatePerformance(String id, Performance performance) async {
    await _firestore
        .collection('performances')
        .doc(id)
        .update(performance.toMap());
  }

  Future<void> deletePerformance(String id) async {
    await _firestore.collection('performances').doc(id).delete();
  }

  Stream<List<Performance>> getPerformancesByStudentId(String studentId) {
    return _firestore
        .collection('performances')
        .where('studentId', isEqualTo: studentId)
        .orderBy('year', descending: true)
        .orderBy('semester', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Performance.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Performance>> getAllPerformances() {
    return _firestore
        .collection('performances')
        .orderBy('year', descending: true)
        .orderBy('semester', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Performance.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<String> exportPerformancesToCSV() async {
    final performances = await _firestore.collection('performances').get();

    // CSV Header
    String csvContent = '년,학기,교번,기수,중대,성명,팔굽혀펴기,윗몸일으키기,달리기\n';

    // Add each performance record
    for (var doc in performances.docs) {
      final data = doc.data();
      csvContent += '${data['year']},${data['semester']},'
          '${data['studentId']},${data['grade']},'
          '${data['unit']},${data['name']},'
          '${data['pushUps']},${data['sitUps']},'
          '${data['running']}\n';
    }

    return csvContent;
  }
}
