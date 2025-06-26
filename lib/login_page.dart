import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart'; // HomePage için eklendi

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _goToHome(context);
    } catch (e) {
      _showError(context, 'Google ile giriş başarısız: $e');
    }
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      _goToHome(context);
    } catch (e) {
      _showError(context, 'Anonim giriş başarısız: $e');
    }
  }

  void _goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Giriş Yap')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Google ile Giriş Yap'),
                onPressed: () => _signInWithGoogle(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text('Misafir Giriş'),
                onPressed: () => _signInAnonymously(context),
              ),
            ],
          ),
        ),
      );
}
