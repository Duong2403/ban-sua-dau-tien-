// lib/models/menu.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  final String id;
  final String mealType;
  final String description;
  final DateTime date;

  Menu({
    required this.id,
    required this.mealType,
    required this.description,
    required this.date,
  });

  factory Menu.fromFirestore(Map<String, dynamic> data, String id) {
    return Menu(
      id: id,
      mealType: data['mealType'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealType': mealType,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }
}
