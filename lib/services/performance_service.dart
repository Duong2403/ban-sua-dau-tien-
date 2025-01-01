// lib/services/performance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance.dart';
import 'package:excel/excel.dart' as excel;

class PerformanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPerformance(Performance performance) async {
    if (performance.studentId.isEmpty || performance.year == 0) {
      throw Exception('Invalid performance data. Please check the inputs.');
    }

    await _firestore.collection('performances').add(performance.toMap());
  }

  Future<void> updatePerformance(String id, Performance performance) async {
    if (performance.studentId.isEmpty || performance.year == 0) {
      throw Exception('Invalid performance data. Please check the inputs.');
    }

    await _firestore
        .collection('performances')
        .doc(id)
        .update(performance.toMap());
  }

  Future<void> deletePerformance(String id) async {
    await _firestore.collection('performances').doc(id).delete();
  }

  Stream<List<Performance>> getPerformancesByStudentId(String studentId) {
    try {
      return _firestore
          .collection('performances')
          .where('studentId', isEqualTo: studentId)
          .orderBy('year', descending: true)
          .orderBy('semester', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Performance.fromFirestore(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error fetching performances for studentId $studentId: $e');
      return const Stream.empty();
    }
  }

  Stream<List<Performance>> getAllPerformances() {
    try {
      return _firestore
          .collection('performances')
          .orderBy('year', descending: true)
          .orderBy('semester', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Performance.fromFirestore(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error fetching all performances: $e');
      return const Stream.empty();
    }
  }

  Future<String> exportPerformancesToCSV() async {
    try {
      final performances = await _firestore.collection('performances').get();

      if (performances.docs.isEmpty) {
        return 'No performance data available.';
      }

      String csvContent =
          'Year,Semester,Student ID,Grade,Unit,Name,Push Ups,Sit Ups,Running\n';

      for (var doc in performances.docs) {
        final data = doc.data();
        csvContent += '${data['year']},${data['semester']},'
            '${data['studentId']},${data['grade']},'
            '${data['unit']},${data['name']},'
            '${data['pushUps']},${data['sitUps']},'
            '${data['running']}\n';
      }

      return csvContent;
    } catch (e) {
      print('Error exporting performances to CSV: $e');
      return 'Error exporting data.';
    }
  }
}
