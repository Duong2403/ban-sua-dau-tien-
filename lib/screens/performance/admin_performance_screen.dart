// lib/screens/performance/admin_performance_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/performance_service.dart';
import '../../models/performance.dart';

class AdminPerformanceScreen extends StatelessWidget {
  final PerformanceService _performanceService = PerformanceService();

  AdminPerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAdminHeader(context),
          const SizedBox(height: 20),
          _buildPerformanceTable(),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '학생 체력 관리',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _handleExportCSV(context),
              icon: const Icon(Icons.file_download),
              label: const Text('CSV 내보내기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTable() {
    return StreamBuilder<List<Performance>>(
      stream: _performanceService.getAllPerformances(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('오류가 발생했습니다: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final performances = snapshot.data ?? [];

        if (performances.isEmpty) {
          return const Center(
            child: Text('등록된 체력 기록이 없습니다.'),
          );
        }

        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('년')),
                DataColumn(label: Text('학기')),
                DataColumn(label: Text('교번')),
                DataColumn(label: Text('기수')),
                DataColumn(label: Text('중대')),
                DataColumn(label: Text('성명')),
                DataColumn(label: Text('팔굽혀펴기')),
                DataColumn(label: Text('윗몸일으키기')),
                DataColumn(label: Text('달리기(분)')),
                DataColumn(label: Text('관리')),
              ],
              rows: performances.map((performance) {
                return DataRow(
                  cells: [
                    DataCell(Text(performance.year.toString())),
                    DataCell(Text(performance.semester.toString())),
                    DataCell(Text(performance.studentId)),
                    DataCell(Text(performance.grade)),
                    DataCell(Text(performance.unit)),
                    DataCell(Text(performance.name)),
                    DataCell(Text(performance.pushUps.toString())),
                    DataCell(Text(performance.sitUps.toString())),
                    DataCell(Text(performance.running.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _handleDelete(context, performance.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleExportCSV(BuildContext context) async {
    try {
      final csvData = await _performanceService.exportPerformancesToCSV();
      await Clipboard.setData(ClipboardData(text: csvData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV 데이터가 클립보드에 복사되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV 내보내기 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, String performanceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 체력 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await _performanceService.deletePerformance(performanceId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기록이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }
}
