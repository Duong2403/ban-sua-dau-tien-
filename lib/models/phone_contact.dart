// lib/models/phone_contact.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneContact {
  final String id;
  final String name;
  final String phone;

  PhoneContact({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory PhoneContact.fromFirestore(Map<String, dynamic> data, String id) {
    return PhoneContact(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
