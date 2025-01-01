// lib/screens/metrics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './grades/admin_grade_screen.dart';
import './grades/student_grade_screen.dart';
import './performance/admin_performance_screen.dart';
import './performance/student_performance_screen.dart';

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
            _buildUnitGradesTab(context),
            _buildPerformanceTab(context),
            _buildStatisticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitGradesTab(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return FutureBuilder<bool>(
      future: authProvider.checkAdminAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isAdmin = snapshot.data ?? false;
        return isAdmin ? const AdminGradeScreen() : StudentGradeScreen();
      },
    );
  }

  Widget _buildPerformanceTab(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    return FutureBuilder<bool>(
      future: authProvider.checkAdminAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isAdmin = snapshot.data ?? false;
        return isAdmin
            ? AdminPerformanceScreen()
            : const StudentPerformanceScreen();
      },
    );
  }

  Widget _buildStatisticsTab() {
    return const Center(
      child: Text(
        'Coming Soon...',
        style: TextStyle(fontSize: 20, color: Colors.grey),
      ),
    );
  }
}
