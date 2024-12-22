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
    return Pass(
      id: id,
      passType: data['passType'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passType': passType,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'userId': userId,
    };
  }
}

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
    return Excusal(
      id: id,
      type: data['type'] ?? '',
      reason: data['reason'] ?? '',
      days: List<String>.from(data['days'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'reason': reason,
      'days': days,
      'startDate': startDate,
      'endDate': endDate,
      'userId': userId,
    };
  }
}

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
    return Metric(
      id: id,
      event: data['event'] ?? '',
      grade: (data['grade'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event': event,
      'grade': grade,
      'date': date,
      'userId': userId,
    };
  }
}

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
    return UserProfile(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      unit: data['unit'] ?? '',
      room: data['room'] ?? '',
      squadron: data['squadron'] ?? '',
    );
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
}