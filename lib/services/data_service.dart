import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../models/menu.dart';

import '../models/phone_contact.dart';
// Trong home_screen.dart và data_service.dart
import '../models/event.dart';
import '../models/schedule.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Menu methods
  Future<void> addMenu(Menu menu) async {
    await _firestore.collection('menus').add(menu.toMap());
  }

  Future<void> updateMenu(String id, Menu menu) async {
    await _firestore.collection('menus').doc(id).update(menu.toMap());
  }

  Future<void> deleteMenu(String id) async {
    await _firestore.collection('menus').doc(id).delete();
  }

  Stream<List<Menu>> getMenus() {
    return _firestore.collection('menus').orderBy('date').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Menu.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Schedule methods

  // Routine order methods
  Future<void> updateRoutineOrder(String uniform) async {
    try {
      final currentUser = FirebaseAuth
          .instance.currentUser; // Lấy thông tin người dùng hiện tại
      await _firestore.collection('routine_orders').doc('current').set({
        'uniform': uniform,
        'date': Timestamp.now(),
        'updatedBy':
            currentUser?.email, // Sử dụng email của người dùng hiện tại
      });
    } catch (e) {
      print('Error updating routine order: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> getRoutineOrder() {
    return _firestore.collection('routine_orders').doc('current').snapshots();
  }

  // Phone contacts methods
  Future<void> addPhoneContact(PhoneContact contact) async {
    await _firestore.collection('phone_contacts').add(contact.toMap());
  }

  Future<void> deletePhoneContact(String id) async {
    await _firestore.collection('phone_contacts').doc(id).delete();
  }

  Stream<List<PhoneContact>> getPhoneContacts() {
    return _firestore
        .collection('phone_contacts')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhoneContact.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Thêm vào class DataService
  Stream<List<Schedule>> getSchedules() {
    return _firestore
        .collection('schedules')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Số lượng document từ Firestore: ${snapshot.docs.length}');
      final schedules = snapshot.docs.map((doc) {
        print('Document data: ${doc.data()}');
        return Schedule.fromFirestore(doc.data(), doc.id);
      }).toList();
      return schedules;
    });
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      print('Đang thêm lịch trình: ${schedule.content}'); // Thêm log
      DocumentReference docRef =
          await _firestore.collection('schedules').add(schedule.toMap());
      print('Lịch trình đã được lưu với ID: ${docRef.id}'); // Thêm log
    } catch (e) {
      print('Lỗi thêm lịch trình: $e');
      rethrow;
    }
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    await _firestore.collection('schedules').doc(id).update(schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    await _firestore.collection('schedules').doc(id).delete();
  }

  Stream<List<PhoneContact>> searchPhoneContacts(String query) {
    return _firestore
        .collection('phone_contacts')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhoneContact.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Future<void> updateEvent(String id, Event event) async {
    await _firestore.collection('events').doc(id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').orderBy('date').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
