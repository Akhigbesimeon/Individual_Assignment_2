import '../screens/login_screen.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkTheme,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF7D94C)),
              ),
              SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
