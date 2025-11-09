import 'package:flutter/material.dart';
import '../providers/bookswap_providers.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/verify_email_screen.dart';
import '../widgets/loading_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (User? user) {
        if (user == null) {
          return LoginScreen();
        } else if (!user.emailVerified) {
          return VerifyEmailScreen();
        } else {
          return MainScreen();
        }
      },
      loading: () => LoadingScreen(message: 'Loading app...'),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Something went wrong: $error'))),
    );
  }
}
