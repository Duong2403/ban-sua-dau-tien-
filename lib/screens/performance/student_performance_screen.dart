import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/performance_service.dart';
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
  final _formKey = GlobalKey<FormState>();

  int _year = DateTime.now().year;
  int _semester = 1;
  int _pushUps = 0;
  int _sitUps = 0;
  double _running = 0.0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final studentId = authProvider.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPerformanceForm(studentId),
            const SizedBox(height: 20),
            const Text(
              'Performance History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPerformanceHistory(studentId),
            const SizedBox(height: 20),
            const Text(
              'Yearly Performance Comparison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPerformanceComparison(studentId),
          ],
        ),
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
                        labelText: 'Year',
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
                        labelText: 'Semester',
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
                        labelText: 'Push Ups',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Enter Push Ups' : null,
                      onSaved: (value) =>
                          _pushUps = int.tryParse(value ?? '0') ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _sitUps.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Sit Ups',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Enter Sit Ups' : null,
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
                  labelText: 'Running Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter Running Time' : null,
                onSaved: (value) =>
                    _running = double.tryParse(value ?? '0') ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitPerformance(studentId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Performance'),
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
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final performances = snapshot.data ?? [];

        if (performances.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No performance records available'),
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Year')),
                DataColumn(label: Text('Semester')),
                DataColumn(label: Text('Push Ups')),
                DataColumn(label: Text('Sit Ups')),
                DataColumn(label: Text('Running (min)')),
                DataColumn(label: Text('Date')),
              ],
              rows: performances.map((performance) {
                return DataRow(
                  cells: [
                    DataCell(Text(performance.year.toString())),
                    DataCell(Text(performance.semester.toString())),
                    DataCell(Text(performance.pushUps.toString())),
                    DataCell(Text(performance.sitUps.toString())),
                    DataCell(Text(performance.running.toStringAsFixed(2))),
                    DataCell(Text(_formatDate(performance.createdAt))),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceComparison(String studentId) {
    return StreamBuilder<List<Performance>>(
      stream: _performanceService.getPerformancesByStudentId(studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final performances = snapshot.data ?? [];

        if (performances.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No comparison data available'),
              ),
            ),
          );
        }

        final years = performances.map((p) => p.year).toSet().toList()..sort();

        return Card(
          child: Column(
            children: years.map((year) {
              final yearlyPerformances =
                  performances.where((p) => p.year == year).toList();
              final averagePushUps = yearlyPerformances
                      .map((p) => p.pushUps)
                      .reduce((a, b) => a + b) /
                  yearlyPerformances.length;
              final averageSitUps = yearlyPerformances
                      .map((p) => p.sitUps)
                      .reduce((a, b) => a + b) /
                  yearlyPerformances.length;
              final averageRunning = yearlyPerformances
                      .map((p) => p.running)
                      .reduce((a, b) => a + b) /
                  yearlyPerformances.length;

              return ListTile(
                title: Text('Year: $year'),
                subtitle: Text(
                  'Average Push Ups: ${averagePushUps.toStringAsFixed(2)}, Average Sit Ups: ${averageSitUps.toStringAsFixed(2)}, Average Running: ${averageRunning.toStringAsFixed(2)} min',
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _submitPerformance(String studentId) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final performance = Performance(
        id: '',
        year: _year,
        semester: _semester,
        studentId: studentId,
        pushUps: _pushUps,
        sitUps: _sitUps,
        running: _running,
        createdAt: DateTime.now(),
        unit: '',
        grade: '',
        name: '',
      );

      try {
        await _performanceService.addPerformance(performance);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Performance saved successfully')),
          );
          setState(() {
            _pushUps = 0;
            _sitUps = 0;
            _running = 0.0;
          });
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
