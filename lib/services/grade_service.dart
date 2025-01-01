import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/grade.dart';

class GradeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Thêm điểm mới
  Future<void> addGrade(Grade grade) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Bạn không có quyền thực hiện thao tác này.');
      }

      // Kiểm tra sự tồn tại của studentId trong collection 'users'
      final userDocs = await _firestore
          .collection('users')
          .where('studentId', isEqualTo: grade.studentId)
          .get();

      if (userDocs.docs.isEmpty) {
        throw Exception('Mã số học viên không tồn tại: ${grade.studentId}');
      }

      await _firestore.collection('grades').add(grade.toMap());
    } catch (e) {
      throw Exception('Không thể thêm điểm: $e');
    }
  }

  // Cập nhật điểm
  Future<void> updateGrade(String id, Grade grade) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Bạn không có quyền thực hiện thao tác này.');
      }

      await _firestore.collection('grades').doc(id).update(grade.toMap());
    } catch (e) {
      throw Exception('Không thể cập nhật điểm: $e');
    }
  }

  // Xóa điểm
  Future<void> deleteGrade(String id) async {
    try {
      if (!await isAdmin()) {
        throw Exception('Bạn không có quyền thực hiện thao tác này.');
      }

      await _firestore.collection('grades').doc(id).delete();
    } catch (e) {
      throw Exception('Không thể xóa điểm: $e');
    }
  }

  // Lấy danh sách điểm theo studentId
  Stream<List<Grade>> getGradesByStudentId(String studentId) {
    try {
      return _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Grade.fromFirestore(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw Exception('Không thể lấy danh sách điểm: $e');
    }
  }

  // Lấy danh sách tất cả điểm
  Stream<List<Grade>> getAllGrades() {
    try {
      return _firestore
          .collection('grades')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Grade.fromFirestore(doc.data(), doc.id))
              .toList());
    } catch (e) {
      throw Exception('Không thể lấy danh sách tất cả điểm: $e');
    }
  }

  // Lấy thống kê điểm
  Future<Map<String, double>> getGradeStatistics(String studentId) async {
    try {
      final grades = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .get();

      if (grades.docs.isEmpty) {
        return {
          'average': 0.0,
          'highest': 0.0,
          'lowest': 0.0,
        };
      }

      final List<double> allGrades = [];
      for (var doc in grades.docs) {
        final grade = Grade.fromFirestore(doc.data(), doc.id);
        final average =
            (grade.regularGrade + grade.midtermGrade + grade.finalGrade) / 3;
        allGrades.add(average);
      }

      allGrades.sort();

      return {
        'average': allGrades.reduce((a, b) => a + b) / allGrades.length,
        'highest': allGrades.last,
        'lowest': allGrades.first,
      };
    } catch (e) {
      throw Exception('Không thể tính toán thống kê điểm: $e');
    }
  }

  // Tìm kiếm điểm
  Future<List<Grade>> searchGrades({
    String? subject,
    String? studentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('grades');

      if (subject != null && subject.isNotEmpty) {
        query = query.where('subject', isEqualTo: subject);
      }

      if (studentId != null && studentId.isNotEmpty) {
        query = query.where('studentId', isEqualTo: studentId);
      }

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) =>
              Grade.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm điểm: $e');
    }
  }

  // Xuất danh sách điểm ra CSV
  Future<String> exportGradesToCSV() async {
    try {
      if (!await isAdmin()) {
        throw Exception('Bạn không có quyền thực hiện thao tác này.');
      }

      final grades = await _firestore.collection('grades').get();

      // Header CSV
      String csvContent =
          'Môn học,Mã môn học,Thường xuyên,Giữa kỳ,Cuối kỳ,Mã học viên,Ngày tạo\n';

      // Thêm từng bản ghi
      for (var doc in grades.docs) {
        final data = doc.data();
        csvContent += '${data['subject']},${data['subjectCode']},'
            '${data['regularGrade']},${data['midtermGrade']},'
            '${data['finalGrade']},${data['studentId']},'
            '${(data['createdAt'] as Timestamp).toDate()}\n';
      }

      return csvContent;
    } catch (e) {
      throw Exception('Không thể xuất danh sách điểm: $e');
    }
  }

  // Kiểm tra quyền admin
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      return user.email ==
          'anhduongxx2403@gmail.com'; // Đổi thành email admin thực tế
    } catch (e) {
      return false;
    }
  }

  // Lấy điểm mới nhất
  Stream<List<Grade>> getLatestGrades(int limit) {
    try {
      return _firestore
          .collection('grades')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Grade.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } catch (e) {
      throw Exception('Không thể lấy danh sách điểm mới nhất: $e');
    }
  }
}
