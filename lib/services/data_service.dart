// lib/services/data_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu.dart';
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
  Future<void> addSchedule(Schedule schedule) async {
    await _firestore.collection('schedules').add(schedule.toMap());
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    await _firestore.collection('schedules').doc(id).update(schedule.toMap());
  }

  Future<void> deleteSchedule(String id) async {
    await _firestore.collection('schedules').doc(id).delete();
  }

  Stream<List<Schedule>> getSchedules() {
    return _firestore.collection('schedules').orderBy('date').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
