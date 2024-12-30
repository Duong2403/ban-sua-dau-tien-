// lib/models/schedule.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Schedule.fromFirestore(Map<String, dynamic> data, String id) {
    return Schedule(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
