import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/grade_service.dart';
import '../../models/grade.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_profile_service.dart';

class StudentGradeScreen extends StatefulWidget {
  const StudentGradeScreen({Key? key}) : super(key: key);

  @override
  State<StudentGradeScreen> createState() => _StudentGradeScreenState();
}

class _StudentGradeScreenState extends State<StudentGradeScreen> {
  final GradeService _gradeService = GradeService();
  final UserProfileService _userProfileService = UserProfileService();
  String? _studentId;
  bool _isLoading = true;
  Map<String, dynamic> _studentProfile = {};

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId != null) {
        final profile = await _userProfileService.getUserProfile(userId);
        if (profile != null) {
          setState(() {
            _studentProfile = profile;
            _studentId = profile['studentId'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading student profile: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studentId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Mã số học viên không tồn tại trong hồ sơ'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin điểm số'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentInfo(),
            const SizedBox(height: 20),
            _buildGradeSummary(),
            const SizedBox(height: 20),
            _buildGradeTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin học viên',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Họ và tên', _studentProfile['name'] ?? 'N/A'),
            _buildInfoRow('Mã học viên', _studentId ?? 'N/A'),
            _buildInfoRow('Chuyên ngành', _studentProfile['major'] ?? 'N/A'),
            _buildInfoRow('Đơn vị', _studentProfile['unit'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildGradeSummary() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getGradesByStudentId(_studentId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Chưa có điểm nào được nhập'),
              ),
            ),
          );
        }

        final grades = snapshot.data!;
        double overallAverage = 0;
        if (grades.isNotEmpty) {
          double total = 0;
          for (var grade in grades) {
            total +=
                (grade.regularGrade + grade.midtermGrade + grade.finalGrade) /
                    3;
          }
          overallAverage = total / grades.length;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng quan điểm số',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard('Tổng môn học', '${grades.length} môn'),
                    _buildSummaryCard('Điểm trung bình',
                        '${overallAverage.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeTable() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getGradesByStudentId(_studentId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Không có điểm nào được nhập'),
              ),
            ),
          );
        }

        final grades = snapshot.data!;

        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Môn học')),
                DataColumn(label: Text('Mã môn học')),
                DataColumn(label: Text('Thường xuyên')),
                DataColumn(label: Text('Giữa kỳ')),
                DataColumn(label: Text('Cuối kỳ')),
                DataColumn(label: Text('Trung bình')),
              ],
              rows: grades.map((grade) {
                final average = (grade.regularGrade +
                        grade.midtermGrade +
                        grade.finalGrade) /
                    3;
                return DataRow(
                  cells: [
                    DataCell(Text(grade.subject)),
                    DataCell(Text(grade.subjectCode)),
                    DataCell(Text(grade.regularGrade.toStringAsFixed(2))),
                    DataCell(Text(grade.midtermGrade.toStringAsFixed(2))),
                    DataCell(Text(grade.finalGrade.toStringAsFixed(2))),
                    DataCell(Text(average.toStringAsFixed(2))),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
