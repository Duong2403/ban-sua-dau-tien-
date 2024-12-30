import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AppAuthProvider() {
    _initialize();
  }

  void _initialize() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> checkAdminAccess() async {
    return await _authService.isAdmin();
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      _user = result?.user;
      return result != null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: $e')),
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
