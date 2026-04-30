// lib/screens/waiting_screen.dart

import 'package:flutter/material.dart';
import '../widgets/buttons.dart';

class WaitingScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const WaitingScreen({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/nnnn.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.25),
            ),
          ),
          // رسالة الانتظار في أسفل الشاشة
          Align(
            alignment: const Alignment(0, 0.75),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Please complete the required data entry.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF25406B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}