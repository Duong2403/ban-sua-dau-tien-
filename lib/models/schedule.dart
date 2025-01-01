import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String content;
  final DateTime date;
  final String userId;
  final bool isPublic;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.content,
    required this.date,
    required this.userId,
    required this.isPublic,
    required this.createdAt,
  });

  factory Schedule.fromFirestore(Map<String, dynamic> data, String id) {
    return Schedule(
      id: id,
      content: data['content'] ?? data['title'] ?? '',
      date: _parseDate(data['date']),
      userId: data['userId'] ?? '',
      isPublic: data['isPublic'] ?? true,
      createdAt: _parseDate(data['createdAt'] ?? DateTime.now()),
    );
  }

  static DateTime _parseDate(dynamic dateData) {
    if (dateData is Timestamp) {
      return dateData.toDate();
    } else if (dateData is String) {
      return DateTime.parse(dateData);
    } else if (dateData is DateTime) {
      return dateData;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'title': content,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
