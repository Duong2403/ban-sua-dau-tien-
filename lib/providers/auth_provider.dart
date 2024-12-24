// lib/providers/app_auth_provider.dart

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

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      _user = result?.user;
      return result != null;
    } catch (e) {
      print('Error in AppAuthProvider.signInWithGoogle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
    } catch (e) {
      print('Error in AppAuthProvider.signOut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
