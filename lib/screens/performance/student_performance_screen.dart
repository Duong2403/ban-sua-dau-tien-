// lib/screens/performance/student_performance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/performance_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/performance.dart';
import '../../providers/auth_provider.dart';

class StudentPerformanceScreen extends StatefulWidget {
  const StudentPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<StudentPerformanceScreen> createState() =>
      _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends State<StudentPerformanceScreen> {
  final PerformanceService _performanceService = PerformanceService();
  final UserProfileService _userProfileService = UserProfileService();
  final _formKey = GlobalKey<FormState>();

  int _year = DateTime.now().year;
  int _semester = 1;
  String _grade = '';
  String _unit = '';
  String _name = '';
  int _pushUps = 0;
  int _sitUps = 0;
  double _running = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final userProfile =
        await _userProfileService.getUserProfile(authProvider.user?.uid ?? '');
    if (userProfile != null) {
      setState(() {
        _grade = userProfile['grade'] ?? '';
        _unit = userProfile['unit'] ?? '';
        _name = userProfile['name'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final studentId = authProvider.user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPerformanceForm(studentId),
          const SizedBox(height: 20),
          _buildPerformanceHistory(studentId),
          const SizedBox(height: 20),
          _buildPerformanceChart(studentId),
        ],
      ),
    );
  }

  Widget _buildPerformanceForm(String studentId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _year,
                      decoration: const InputDecoration(
                        labelText: '년 (Year)',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) {
                        final year = DateTime.now().year - 2 + index;
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }),
                      onChanged: (value) => setState(() => _year = value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _semester,
                      decoration: const InputDecoration(
                        labelText: '학기 (Semester)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1')),
                        DropdownMenuItem(value: 2, child: Text('2')),
                      ],
                      onChanged: (value) => setState(() => _semester = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _pushUps.toString(),
                      decoration: const InputDecoration(
                        labelText: '팔굽혀펴기 (Push-ups)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '푸시업 횟수를 입력하세요' : null,
                      onSaved: (value) =>
                          _pushUps = int.tryParse(value ?? '0') ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _sitUps.toString(),
                      decoration: const InputDecoration(
                        labelText: '윗몸일으키기 (Sit-ups)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '싯업 횟수를 입력하세요' : null,
                      onSaved: (value) =>
                          _sitUps = int.tryParse(value ?? '0') ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _running.toString(),
                decoration: const InputDecoration(
                  labelText: '달리기 (Running time in minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? '달리기 시간을 입력하세요' : null,
                onSaved: (value) =>
                    _running = double.tryParse(value ?? '0') ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitPerformance(studentId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('기록 입력 (Submit Performance)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceHistory(String studentId) {
    return StreamBuilder<List<Performance>>(
      stream: _performanceService.getPerformancesByStudentId(studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading performance data');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final performances = snapshot.data ?? [];

        if (performances.isEmpty) {
          return const Center(
            child: Text('아직 입력된 기록이 없습니다'),
          );
        }

        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('년')),
                DataColumn(label: Text('학기')),
                DataColumn(label: Text('팔굽혀펴기')),
                DataColumn(label: Text('윗몸일으키기')),
                DataColumn(label: Text('달리기')),
              ],
              rows: performances
                  .map((performance) => DataRow(
                        cells: [
                          DataCell(Text(performance.year.toString())),
                          DataCell(Text(performance.semester.toString())),
                          DataCell(Text(performance.pushUps.toString())),
                          DataCell(Text(performance.sitUps.toString())),
                          DataCell(Text('${performance.running} min')),
                        ],
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart(String studentId) {
    // Will implement chart visualization in the next part
    return Container();
  }

  // lib/screens/performance/student_performance_screen.dart

  Future<void> _submitPerformance(String studentId) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final performance = Performance(
        id: '',
        year: _year,
        semester: _semester,
        studentId: studentId,
        grade: _grade,
        unit: _unit,
        name: _name,
        pushUps: _pushUps,
        sitUps: _sitUps,
        running: _running,
        createdAt: DateTime.now(),
      );

      try {
        await _performanceService.addPerformance(performance);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기록이 성공적으로 저장되었습니다')),
          );
          _formKey.currentState?.reset();
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
}
