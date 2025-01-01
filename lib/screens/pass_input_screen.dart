import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PassInputScreen extends StatefulWidget {
  const PassInputScreen({Key? key}) : super(key: key);

  @override
  State<PassInputScreen> createState() => _PassInputScreenState();
}

class _PassInputScreenState extends State<PassInputScreen> {
  final _formKey = GlobalKey<FormState>();
  String _passType = '외출';
  String _address = '';
  String _time = '';
  String _description = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('passes').add({
          'passType': _passType,
          'address': _address,
          'time': _time,
          'description': _description,
          'submittedBy': currentUser?.email,
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi thông tin thành công!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký Pass')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _passType,
                items: const [
                  DropdownMenuItem(value: '외출', child: Text('외출')),
                  DropdownMenuItem(value: '병원', child: Text('병원')),
                  DropdownMenuItem(value: '특박', child: Text('특박')),
                  DropdownMenuItem(value: '청원휴가', child: Text('청원휴가')),
                ],
                onChanged: (value) => setState(() => _passType = value!),
                decoration: const InputDecoration(labelText: 'Loại Pass'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                onSaved: (value) => _address = value!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Thời gian'),
                onSaved: (value) => _time = value!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mô tả'),
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Gửi thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
