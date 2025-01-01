import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPassScreen extends StatelessWidget {
  const AdminPassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Pass')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('passes')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final passes = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Loại Pass')),
                DataColumn(label: Text('Địa chỉ')),
                DataColumn(label: Text('Thời gian')),
                DataColumn(label: Text('Mô tả')),
                DataColumn(label: Text('Học viên')),
              ],
              rows: passes.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['passType'] ?? '')),
                  DataCell(Text(data['address'] ?? '')),
                  DataCell(Text(data['time'] ?? '')),
                  DataCell(Text(data['description'] ?? '')),
                  DataCell(Text(data['submittedBy'] ?? '')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
