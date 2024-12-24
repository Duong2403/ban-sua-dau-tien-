// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Academy Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else if (kIsWeb)
              // Web platform - use renderButton
              GoogleSignInButton(
                onPressed: () async {
                  final success = await authProvider.signInWithGoogle(context);
                  if (success && context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
              )
            else
              // Mobile platforms - use custom button
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.signInWithGoogle(context);
                  if (success && context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.g_mobiledata, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                height: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
