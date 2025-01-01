import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// [Phần còn lại giữ nguyên như code trước]

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool isEditing = false;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (profile != null) {
        setState(() {
          userData = profile;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('본인 정보'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () => _handleEditSave(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfo(),
              const SizedBox(height: 24),
              _buildAcademyInfo(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin cá nhân',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildTextField('name', 'Họ và tên', Icons.person),
        const SizedBox(height: 12),
        _buildTextField('phone', 'Số điện thoại', Icons.phone),
        const SizedBox(height: 12),
        _buildTextField('email', 'Email', Icons.email, enabled: false),
      ],
    );
  }

  Widget _buildAcademyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin học viện',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildTextField('unit', '중대', Icons.business),
        const SizedBox(height: 12),
        _buildTextField('room', '호실', Icons.room),
        const SizedBox(height: 12),
        _buildTextField('squadron', '대대', Icons.group),
        const SizedBox(height: 12),
        _buildTextField('studentId', '교번 ', Icons.school),
        const SizedBox(height: 12),
        _buildTextField('major', 'mafor', Icons.book),
      ],
    );
  }

  Widget _buildTextField(
    String field,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: userData[field] ?? '',
      enabled: enabled && isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: (value) => userData[field] = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _handleLogout(),
        child: const Text(
          'Đăng xuất',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleEditSave() async {
    if (isEditing) {
      if (_formKey.currentState!.validate()) {
        final user = _authService.currentUser;
        if (user != null) {
          await _authService.updateProfile(user.uid, userData);
          setState(() => isEditing = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật hồ sơ')),
            );
          }
        }
      }
    } else {
      setState(() => isEditing = true);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
