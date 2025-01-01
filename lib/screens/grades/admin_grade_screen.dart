// lib/screens/grades/admin_grade_screen.dart
import 'package:flutter/material.dart';
import '../../services/grade_service.dart';
import '../../models/grade.dart';

class AdminGradeScreen extends StatefulWidget {
  const AdminGradeScreen({Key? key}) : super(key: key);

  @override
  State<AdminGradeScreen> createState() => _AdminGradeScreenState();
}

class _AdminGradeScreenState extends State<AdminGradeScreen> {
  final GradeService _gradeService = GradeService();
  final _formKey = GlobalKey<FormState>();

  String _subject = '';
  String _subjectCode = '';
  double _regularGrade = 0;
  double _midtermGrade = 0;
  double _finalGrade = 0;
  String _studentId = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Grade Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildGradeForm(),
          const SizedBox(height: 20),
          _buildGradesList(),
        ],
      ),
    );
  }

  Widget _buildGradeForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '과목 (Subject)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? '과목을 입력하세요' : null,
                onSaved: (value) => _subject = value ?? '',
              ),
              const SizedBox(height: 12),
              // ... [Other form fields remain the same]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradesList() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getAllGrades(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading grades');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final grades = snapshot.data ?? [];

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
                DataColumn(label: Text('교번')),
                DataColumn(label: Text('Actions')),
              ],
              rows: grades
                  .map((grade) => DataRow(
                        cells: [
                          DataCell(Text(grade.subject)),
                          DataCell(Text(grade.subjectCode)),
                          DataCell(Text(grade.regularGrade.toString())),
                          DataCell(Text(grade.midtermGrade.toString())),
                          DataCell(Text(grade.finalGrade.toString())),
                          DataCell(Text(grade.studentId)),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteGrade(grade.id),
                          )),
                        ],
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteGrade(String id) async {
    try {
      await _gradeService.deleteGrade(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성적이 삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
