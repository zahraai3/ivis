import 'package:flutter/material.dart';

// ── زر الاختيار الكبير المستدير ──────────────────────────
// يستخدم في كل شاشات الاختيار (السعة، المجموعة، النوع)
// Material + InkWell أفضل من ElevatedButton لأنه يعطي تحكم كامل بالشكل
class BigPillButton extends StatelessWidget {
  final String text;       // النص على الزر
  final VoidCallback onTap; // الدالة التي تُستدعى عند الضغط

  const BigPillButton({super.key,required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const StadiumBorder(), // شكل بيضاوي/Pill
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(), // تأثير الموجة يتبع الشكل
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF25406B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ── شريط الأزرار السفلي ───────────────────────────────────
// يظهر في أسفل شاشات الإعداد (0-3)
// يحتوي زر Back (دائماً يسار) + زر Send (في المنتصف، يظهر فقط في step 3)
class BottomBar extends StatelessWidget {
  final bool showBack; // هل نعرض زر Back؟
  final bool showSend; // هل نعرض زر Send؟
  final VoidCallback onBack;
  final VoidCallback onSend;

  const BottomBar({
    super.key,
    required this.showBack,
    required this.showSend,
    required this.onBack,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: BottomBack(onTap: onBack),
            ),
          if (showSend)
            Align(
              alignment: Alignment.center,
              child: SendButton(onTap: onSend),
            ),
        ],
      ),
    );
  }
}

// ── زر Back ───────────────────────────────────────────────
class BottomBack extends StatelessWidget {
  final VoidCallback onTap;
  const BottomBack({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF25406B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ── زر Send ───────────────────────────────────────────────
// يظهر فقط في شاشة الملخص (step 3)
// لونه رمادي عشان يبيّن إنه إجراء نهائي
class SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const SendButton({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF9E9E9E), // رمادي
      shape: const StadiumBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
          child: Text(
            'Send',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ── زر Logout العائم ──────────────────────────────────────
// يظهر في الزاوية العلوية اليسرى في كل الشاشات ما عدا شاشة الدخول
// Positioned في build() يضعه فوق كل شيء
class LogoutPill extends StatelessWidget {
  final VoidCallback onTap;
  const LogoutPill({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFF25406B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}