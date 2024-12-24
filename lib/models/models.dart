import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a pass in the system
class Pass {
  final String id;
  final String passType;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String userId;

  Pass({
    required this.id,
    required this.passType,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.userId,
  });

  factory Pass.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return Pass(
        id: id,
        passType: data['passType'] as String? ?? '',
        startTime:
            (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: data['status'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Error converting Pass from Firestore: $e',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'passType': passType,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
      'userId': userId,
    };
  }

  /// Creates a copy of Pass with optional new values
  Pass copyWith({
    String? passType,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? userId,
  }) {
    return Pass(
      id: id,
      passType: passType ?? this.passType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }
}

/// Represents an excusal in the system
class Excusal {
  final String id;
  final String type;
  final String reason;
  final List<String> days;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;

  Excusal({
    required this.id,
    required this.type,
    required this.reason,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.userId,
  });

  factory Excusal.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return Excusal(
        id: id,
        type: data['type'] as String? ?? '',
        reason: data['reason'] as String? ?? '',
        days: List<String>.from(data['days'] ?? []),
        startDate:
            (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        userId: data['userId'] as String? ?? '',
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Error converting Excusal from Firestore: $e',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'reason': reason,
      'days': days,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'userId': userId,
    };
  }

  Excusal copyWith({
    String? type,
    String? reason,
    List<String>? days,
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) {
    return Excusal(
      id: id,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      days: days ?? List.from(this.days),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
    );
  }
}

/// Represents a metric/grade in the system
class Metric {
  final String id;
  final String event;
  final double grade;
  final DateTime date;
  final String userId;

  Metric({
    required this.id,
    required this.event,
    required this.grade,
    required this.date,
    required this.userId,
  });

  factory Metric.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return Metric(
        id: id,
        event: data['event'] as String? ?? '',
        grade: (data['grade'] as num?)?.toDouble() ?? 0.0,
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        userId: data['userId'] as String? ?? '',
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Error converting Metric from Firestore: $e',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'event': event,
      'grade': grade,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }

  Metric copyWith({
    String? event,
    double? grade,
    DateTime? date,
    String? userId,
  }) {
    return Metric(
      id: id,
      event: event ?? this.event,
      grade: grade ?? this.grade,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }
}

/// Represents a user profile in the system
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String unit;
  final String room;
  final String squadron;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.unit,
    required this.room,
    required this.squadron,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return UserProfile(
        id: id,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        unit: data['unit'] as String? ?? '',
        room: data['room'] as String? ?? '',
        squadron: data['squadron'] as String? ?? '',
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Error converting UserProfile from Firestore: $e',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'unit': unit,
      'room': room,
      'squadron': squadron,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? unit,
    String? room,
    String? squadron,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      unit: unit ?? this.unit,
      room: room ?? this.room,
      squadron: squadron ?? this.squadron,
    );
  }
}
