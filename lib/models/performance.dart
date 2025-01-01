// lib/models/performance.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Performance {
  final String id;
  final int year; // 년
  final int semester; // 학기
  final String studentId; // 교번
  final String grade; // 기수
  final String unit; // 중대
  final String name; // 성명
  final int pushUps; // 팔굽혀펴기
  final int sitUps; // 윗몸일으키기
  final double running; // 달리기
  final DateTime createdAt;

  Performance({
    required this.id,
    required this.year,
    required this.semester,
    required this.studentId,
    required this.grade,
    required this.unit,
    required this.name,
    required this.pushUps,
    required this.sitUps,
    required this.running,
    required this.createdAt,
  });

  factory Performance.fromFirestore(Map<String, dynamic> data, String id) {
    return Performance(
      id: id,
      year: data['year'] ?? 0,
      semester: data['semester'] ?? 0,
      studentId: data['studentId'] ?? '',
      grade: data['grade'] ?? '',
      unit: data['unit'] ?? '',
      name: data['name'] ?? '',
      pushUps: data['pushUps'] ?? 0,
      sitUps: data['sitUps'] ?? 0,
      running: (data['running'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'semester': semester,
      'studentId': studentId,
      'grade': grade,
      'unit': unit,
      'name': name,
      'pushUps': pushUps,
      'sitUps': sitUps,
      'running': running,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
