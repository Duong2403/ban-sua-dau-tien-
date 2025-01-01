// lib/screens/grades/student_grade_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/grade_service.dart';
import '../../models/grade.dart';
import '../../providers/auth_provider.dart';

class StudentGradeScreen extends StatelessWidget {
  final GradeService _gradeService = GradeService();

  StudentGradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final studentId = authProvider.user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성적 현황 (Grade Status)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildGradeTable(studentId),
        ],
      ),
    );
  }

  Widget _buildGradeTable(String studentId) {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getGradesByStudentId(studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading grades');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final grades = snapshot.data ?? [];

        if (grades.isEmpty) {
          return const Center(
            child: Text('아직 입력된 성적이 없습니다'),
          );
        }

        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('과목')),
                DataColumn(label: Text('과목코드')),
                DataColumn(label: Text('수시')),
                DataColumn(label: Text('중간')),
                DataColumn(label: Text('기말')),
                DataColumn(label: Text('평균')),
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
                    DataCell(Text(grade.regularGrade.toString())),
                    DataCell(Text(grade.midtermGrade.toString())),
                    DataCell(Text(grade.finalGrade.toString())),
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
