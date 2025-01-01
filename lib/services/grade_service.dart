// lib/services/grade_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/grade.dart';

class GradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CRUD Operations for Grades
  Future<void> addGrade(Grade grade) async {
    try {
      if (!await isAdmin()) {
        throw Exception('권한이 없습니다');
      }
      await _firestore.collection('grades').add(grade.toMap());
    } catch (e) {
      throw Exception('성적 추가 실패: $e');
    }
  }

  Future<void> updateGrade(String id, Grade grade) async {
    try {
      if (!await isAdmin()) {
        throw Exception('권한이 없습니다');
      }
      await _firestore.collection('grades').doc(id).update(grade.toMap());
    } catch (e) {
      throw Exception('성적 업데이트 실패: $e');
    }
  }

  Future<void> deleteGrade(String id) async {
    try {
      if (!await isAdmin()) {
        throw Exception('권한이 없습니다');
      }
      await _firestore.collection('grades').doc(id).delete();
    } catch (e) {
      throw Exception('성적 삭제 실패: $e');
    }
  }

  // Read Grade methods
  Stream<List<Grade>> getGradesByStudentId(String studentId) {
    try {
      return _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Grade.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } catch (e) {
      throw Exception('성적 조회 실패: $e');
    }
  }

  Stream<List<Grade>> getAllGrades() {
    try {
      return _firestore
          .collection('grades')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Grade.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } catch (e) {
      throw Exception('전체 성적 조회 실패: $e');
    }
  }

  // Grade Statistics methods
  Future<Map<String, double>> getGradeStatistics(String studentId) async {
    try {
      final grades = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (grades.docs.isEmpty) {
        return {
          'average': 0.0,
          'highest': 0.0,
          'lowest': 0.0,
        };
      }

      final List<double> allGrades = [];
      for (var doc in grades.docs) {
        final grade = Grade.fromFirestore(doc.data(), doc.id);
        final average =
            (grade.regularGrade + grade.midtermGrade + grade.finalGrade) / 3;
        allGrades.add(average);
      }

      allGrades.sort();

      return {
        'average': allGrades.reduce((a, b) => a + b) / allGrades.length,
        'highest': allGrades.last,
        'lowest': allGrades.first,
      };
    } catch (e) {
      throw Exception('성적 통계 계산 실패: $e');
    }
  }

  // Search and Filter methods
  Future<List<Grade>> searchGrades({
    String? subject,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('grades');

      if (subject != null && subject.isNotEmpty) {
        query = query.where('subject', isEqualTo: subject);
      }

      if (studentId != null && studentId.isNotEmpty) {
        query = query.where('studentId', isEqualTo: studentId);
      }

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) =>
              Grade.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('성적 검색 실패: $e');
    }
  }

  // Export methods
  Future<String> exportGradesToCSV() async {
    try {
      if (!await isAdmin()) {
        throw Exception('권한이 없습니다');
      }

      final grades = await _firestore.collection('grades').get();

      // CSV Header
      String csvContent = '과목,과목코드,수시,중간,기말,교번,생성일자\n';

      // Add each grade record
      for (var doc in grades.docs) {
        final data = doc.data();
        csvContent += '${data['subject']},${data['subjectCode']},'
            '${data['regularGrade']},${data['midtermGrade']},'
            '${data['finalGrade']},${data['studentId']},'
            '${(data['createdAt'] as Timestamp).toDate().toString()}\n';
      }

      return csvContent;
    } catch (e) {
      throw Exception('성적 내보내기 실패: $e');
    }
  }

  // Authorization method
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      return user.email == 'anhduongxx2403@gmail.com';
    } catch (e) {
      return false;
    }
  }

  // Get Single Grade
  Future<Grade?> getGrade(String id) async {
    try {
      final doc = await _firestore.collection('grades').doc(id).get();
      if (!doc.exists) return null;
      return Grade.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('성적 조회 실패: $e');
    }
  }

  // Get Latest Grades
  Stream<List<Grade>> getLatestGrades(int limit) {
    try {
      return _firestore
          .collection('grades')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Grade.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } catch (e) {
      throw Exception('최근 성적 조회 실패: $e');
    }
  }
}
