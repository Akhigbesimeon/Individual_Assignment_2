import 'dart:async';
import '../providers/bookswap_providers.dart';
import '../screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      ref.read(authServiceProvider).currentUser?.reload();
      final user = ref.read(authServiceProvider).currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    final authService = ref.read(authServiceProvider);
    await authService.resendEmailVerification();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Verification email sent!')));
  }

  Future<void> _signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;

    return Theme(
      data: darkTheme,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.email, size: 80, color: Color(0xFFF7D94C)),
                SizedBox(height: 24),
                Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'A verification link has been sent to:\n${user?.email ?? 'your email'}\n\nPlease check your inbox and spam folder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _resendEmail,
                  child: Text('Resend Email'),
                ),
                SizedBox(height: 16),
                TextButton(onPressed: _signOut, child: Text('Sign out')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
