// lib/screens/monitor_screen.dart
// تعرض نسبة السيروم المتبقية % وتتحدث كل ثانية
import 'package:flutter/material.dart';
import '../widgets/buttons.dart';

class MonitorScreen extends StatelessWidget {
  final double remaining;
  final VoidCallback onLogout;

  const MonitorScreen({
    super.key,
    required this.remaining,
    required this.onLogout,
  });

  Color _getColor(double value) {
    if (value <= 10) return Colors.red;
    if (value < 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(remaining);

    return Scaffold(
      body: Stack(
        children: [
          // صورة الخلفية
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrawnd.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          // صورة كيس السيروم في الزاوية السفلى اليمنى
          Positioned(
            right: -10,
            bottom: -10,
            child: Image.asset(
              'assets/images/iv.png',
              width: 330,
              fit: BoxFit.contain,
            ),
          ),
          // البطاقة الرئيسية في المنتصف
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Remaining %',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF20375C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // الرقم الكبير — لونه يتغير حسب النسبة
                  Text(
                    '${remaining.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // شريط التقدم (Progress Bar)
                  // عرضه الكلي 220px × نسبة المتبقي = العرض الملوّن
                  Container(
                    width: 220,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade300,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 220 * (remaining.clamp(0, 100) / 100),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
