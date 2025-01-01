// lib/models/grade.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Grade {
  final String id;
  final String subject; // 과목
  final String subjectCode; // 과목코드
  final double regularGrade; // 수시
  final double midtermGrade; // 중간
  final double finalGrade; // 기말
  final String studentId; // 교번
  final DateTime createdAt;

  Grade({
    required this.id,
    required this.subject,
    required this.subjectCode,
    required this.regularGrade,
    required this.midtermGrade,
    required this.finalGrade,
    required this.studentId,
    required this.createdAt,
  });

  factory Grade.fromFirestore(Map<String, dynamic> data, String id) {
    return Grade(
      id: id,
      subject: data['subject'] ?? '',
      subjectCode: data['subjectCode'] ?? '',
      regularGrade: (data['regularGrade'] ?? 0.0).toDouble(),
      midtermGrade: (data['midtermGrade'] ?? 0.0).toDouble(),
      finalGrade: (data['finalGrade'] ?? 0.0).toDouble(),
      studentId: data['studentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'subjectCode': subjectCode,
      'regularGrade': regularGrade,
      'midtermGrade': midtermGrade,
      'finalGrade': finalGrade,
      'studentId': studentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
