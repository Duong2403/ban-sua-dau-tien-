import 'package:flutter/material.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Metrics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Unit Grades'),
              Tab(text: 'Performance'),
              Tab(text: 'Statistics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUnitGradesTab(),
            _buildPerformanceTab(),
            _buildStatisticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitGradesTab() {
    final grades = [
      {'event': 'AMI 1', 'grade': 71.0, 'date': '2024-01-05'},
      {'event': 'AMI 2', 'grade': 92.0, 'date': '2024-01-12'},
      {'event': 'AMI 3', 'grade': 100.0, 'date': '2024-01-19'},
      {'event': 'AMI 4', 'grade': 96.0, 'date': '2024-01-26'},
      {'event': 'AMI 5', 'grade': 100.0, 'date': '2024-02-02'},
      {'event': 'AMI 6', 'grade': 96.0, 'date': '2024-02-09'},
      {'event': 'AMI 7', 'grade': 100.0, 'date': '2024-02-16'},
      {'event': 'CAI 1', 'grade': 100.0, 'date': '2024-02-23'},
      {'event': 'CAI 2', 'grade': 100.0, 'date': '2024-03-01'},
      {'event': 'CAI 3', 'grade': 100.0, 'date': '2024-03-08'},
      {'event': 'SAMI 2', 'grade': 88.0, 'date': '2024-03-15'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildGradeSummaryCards(grades),
          const SizedBox(height: 16),
          _buildGradesTable(grades),
        ],
      ),
    );
  }

  Widget _buildGradeSummaryCards(List<Map<String, dynamic>> grades) {
    double average = grades.map((g) => g['grade'] as double).reduce((a, b) => a + b) / grades.length;
    double highest = grades.map((g) => g['grade'] as double).reduce((a, b) => a > b ? a : b);
    double lowest = grades.map((g) => g['grade'] as double).reduce((a, b) => a < b ? a : b);

    return Row(
      children: [
        _buildSummaryCard('Average', average.toStringAsFixed(1), Colors.blue),
        const SizedBox(width: 8),
        _buildSummaryCard('Highest', highest.toStringAsFixed(1), Colors.green),
        const SizedBox(width: 8),
        _buildSummaryCard('Lowest', lowest.toStringAsFixed(1), Colors.red),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradesTable(List<Map<String, dynamic>> grades) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Event')),
          DataColumn(label: Text('Grade'), numeric: true),
          DataColumn(label: Text('Date')),
        ],
        rows: grades.map((grade) {
          return DataRow(
            cells: [
              DataCell(Text(grade['event'].toString())),
              DataCell(
                Text(
                  grade['grade'].toStringAsFixed(1),
                  style: TextStyle(
                    color: _getGradeColor(grade['grade'] as double),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(Text(grade['date'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 95) return Colors.green;
    if (grade >= 85) return Colors.blue;
    if (grade >= 75) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPerformanceTab() {
    return const Center(
      child: Text('Performance metrics coming soon'),
    );
  }

  Widget _buildStatisticsTab() {
    return const Center(
      child: Text('Statistics coming soon'),
    );
  }
}