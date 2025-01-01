import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isSubmitting = false;

  // Controllers
  final _subjectController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _regularGradeController = TextEditingController();
  final _midtermGradeController = TextEditingController();
  final _finalGradeController = TextEditingController();
  final _studentIdController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _subjectCodeController.dispose();
    _regularGradeController.dispose();
    _midtermGradeController.dispose();
    _finalGradeController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _subjectController.clear();
    _subjectCodeController.clear();
    _regularGradeController.clear();
    _midtermGradeController.clear();
    _finalGradeController.clear();
    _studentIdController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý điểm (Grade Management)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nhập điểm cho học viên',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildGradeForm(),
            const SizedBox(height: 20),
            _buildGradesList(),
          ],
        ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Môn học (Subject)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập môn học' : null,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã môn học (Subject Code)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Vui lòng nhập mã môn học' : null,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _regularGradeController,
                      decoration: const InputDecoration(
                        labelText: 'Điểm thường xuyên (Regular)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: _validateGrade,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _midtermGradeController,
                      decoration: const InputDecoration(
                        labelText: 'Điểm giữa kỳ (Midterm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: _validateGrade,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _finalGradeController,
                      decoration: const InputDecoration(
                        labelText: 'Điểm cuối kỳ (Final)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: _validateGrade,
                      enabled: !_isSubmitting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Mã số học viên (Student ID)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Vui lòng nhập mã số học viên'
                    : null,
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitGrade,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Nhập điểm (Submit Grade)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateGrade(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập điểm';
    }
    final grade = double.tryParse(value);
    if (grade == null) {
      return 'Điểm không hợp lệ';
    }
    if (grade < 0 || grade > 100) {
      return 'Điểm phải trong khoảng 0 - 100';
    }
    return null;
  }

  Widget _buildGradesList() {
    return StreamBuilder<List<Grade>>(
      stream: _gradeService.getAllGrades(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Lỗi khi tải danh sách điểm: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final grades = snapshot.data ?? [];

        if (grades.isEmpty) {
          return const Center(
            child: Text('Chưa có điểm nào được nhập.'),
          );
        }

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
                DataColumn(label: Text('Mã học viên')),
                DataColumn(label: Text('Hành động')),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
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

  Future<void> _submitGrade() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        final studentId = _studentIdController.text.trim();

        // Kiểm tra tồn tại của studentId
        final userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('studentId', isEqualTo: studentId)
            .get();

        if (userDocs.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mã số học viên không tồn tại.')),
          );
          return;
        }

        final grade = Grade(
          id: '',
          subject: _subjectController.text.trim(),
          subjectCode: _subjectCodeController.text.trim(),
          regularGrade: double.parse(_regularGradeController.text),
          midtermGrade: double.parse(_midtermGradeController.text),
          finalGrade: double.parse(_finalGradeController.text),
          studentId: studentId,
          createdAt: DateTime.now(),
        );

        await _gradeService.addGrade(grade);
        _clearForm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Điểm đã được nhập thành công.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi nhập điểm: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteGrade(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa điểm'),
        content: const Text('Bạn có chắc chắn muốn xóa điểm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _gradeService.deleteGrade(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Điểm đã được xóa thành công.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa điểm: $e')),
        );
      }
    }
  }
}
