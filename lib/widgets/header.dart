import 'package:flutter/material.dart';
// ── عنوان الشاشة ─────────────────────────────────────────
// يعرض سطر من كلمتين — الأولى زرقاء والثانية بيضاء
// مثال: "SELECT" (أزرق) + "CAPACITY" (أبيض)
class Header extends StatelessWidget {
  final String title1; // الجزء الأزرق
  final String title2; // الجزء الأبيض

  const Header({super.key,required this.title1, required this.title2});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        // RichText يسمح لنا بتلوين كل كلمة بشكل مستقل
        text: TextSpan(
          style: const TextStyle(fontSize: 26),
          children: [
            TextSpan(
              text: '$title1 ',
              style: const TextStyle(
                color: Color(0xFF005BA7),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: title2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

