// lib/screens/waiting_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';

class WaitingScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const WaitingScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {

  // ── متحكمات الـ Animation ──────────────────────────────
  // كل نقطة من النقاط الثلاث لها animation مستقلة
  late final AnimationController _dot1Ctrl;
  late final AnimationController _dot2Ctrl;
  late final AnimationController _dot3Ctrl;

  // animation النبض على الأيقونة الدائرية
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // animation ظهور البطاقة عند فتح الشاشة (fade + slide)
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // ── Fade + Slide للبطاقة عند الدخول ──
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();

    // ── Pulse للأيقونة — نبضة هادئة مستمرة ──
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── النقاط الثلاث — كل نقطة تبدأ بتأخير مختلف ──
    _dot1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _dot2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // نقطة 2 تبدأ بعد 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _dot2Ctrl.repeat(reverse: true);
    });

    _dot3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // نقطة 3 تبدأ بعد 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _dot3Ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    // تحرير كل الـ controllers عند إغلاق الشاشة
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _dot1Ctrl.dispose();
    _dot2Ctrl.dispose();
    _dot3Ctrl.dispose();
    super.dispose();
  }

  // ── بناء نقطة واحدة متحركة ──
  Widget _buildDot(AnimationController ctrl) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(
            // تتراوح الشفافية بين 0.25 و 1.0
            0.25 + (ctrl.value * 0.75),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── خلفية gradient متطابقة مع شاشات الإعداد ──
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),

          // ── صورة كيس السيروم في الزاوية السفلى اليمنى ──
          // نفس أسلوب monitor_screen للتناسق
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.13,
              child: Image.asset(
                'assets/images/iv.png',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ── المحتوى الرئيسي ──
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── الأيقونة الدائرية مع نبضة ──
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.30),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.wifi_rounded,
                              color: AppColors.textOnPrimary,
                              size: 38,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // ── البطاقة البيضاء ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceLG,
                            vertical: AppDimensions.spaceXL,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXL),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── العنوان ──
                              Text(
                                'Waiting for Device',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.spaceSM),

                              // ── الرسالة التوضيحية ──
                              Text(
                                'Setup sent successfully.\nWaiting for the device to start...',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.spaceLG),

                              // ── النقاط المتحركة ──
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDot(_dot1Ctrl),
                                  const SizedBox(width: 10),
                                  _buildDot(_dot2Ctrl),
                                  const SizedBox(width: 10),
                                  _buildDot(_dot3Ctrl),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}