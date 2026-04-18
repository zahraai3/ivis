import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// ── حقل الإدخال في شاشة الدخول ───────────────────────────

// مخصص للاسم ورقم الهاتف
// نفصله عن الـ TextField العادي عشان له ستايل موحد ونستخدمه مرتين
class IntroField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;                        // النص التوضيحي
  final TextInputType? keyboardType;        // نوع لوحة المفاتيح (اختياري)

  const IntroField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF25406B),
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF25406B),
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF25406B), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF005BA7), width: 2.5),
          ),
        ),
      ),
    );
  }
}
