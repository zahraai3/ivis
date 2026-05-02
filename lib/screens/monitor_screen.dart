// lib/screens/monitor_screen.dart
// ============================================================
// شاشة المراقبة الحية — تعرض نسبة السيروم المتبقية %
// تتحدث كل ثانية من _fetchStatus() في main.dart
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';

class MonitorScreen extends StatelessWidget {
  final double remaining; // نسبة السيروم المتبقية (0-100)
  final String room;      // رقم الغرفة — يُعرض للتأكيد
  final VoidCallback onLogout;

  const MonitorScreen({
    super.key,
    required this.remaining,
    required this.room,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // ── جلب بيانات الحالة من IVStatusHelper (موجود في app_theme.dart) ──
    // هذي الدوال تحدد اللون والنص والأيقونة حسب النسبة
    final color   = IVStatusHelper.percentColor(remaining);
    final bgColor = IVStatusHelper.percentBgColor(remaining);
    final label   = IVStatusHelper.percentLabel(remaining);
    final icon    = IVStatusHelper.percentIcon(remaining);

    return Scaffold(
      body: Stack(
        children: [
          // ── خلفية gradient متطابقة مع باقي شاشات التطبيق ──
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),

          // ── صورة كيس السيروم ديكور في الزاوية السفلى ──
          Positioned(
            right: 50,
            bottom: 110,
            child: Opacity(
              opacity: 0.75,
              child: Image.asset(
                'assets/images/diffiv.jpg',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ── المحتوى الرئيسي ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50), // مساحة لزر Logout

                  // ── الهيدر: حالة + غرفة ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // badge الحالة — يتغير لون وأيقونة حسب النسبة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMD,
                          vertical: AppDimensions.spaceSM,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: color.withOpacity(0.3), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: color, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // badge رقم الغرفة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMD,
                          vertical: AppDimensions.spaceSM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: AppColors.border, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.meeting_room_rounded,
                              color: Color(0xFF7C3AED),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Room $room',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── البطاقة الرئيسية ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLG,
                      vertical: AppDimensions.spaceXL,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // عنوان
                        Text(
                          'Remaining',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // الرقم الكبير — لونه يتغير حسب النسبة
                        Text(
                          '${remaining.toStringAsFixed(0)}%',
                          style: AppTextStyles.monitorDisplay.copyWith(
                            color: color,
                            fontSize: 80,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // شريط التقدم
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          child: LinearProgressIndicator(
                            value: remaining.clamp(0, 100) / 100,
                            minHeight: 14,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceSM),

                        // labels أطراف الشريط
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0%', style: AppTextStyles.bodySmall),
                            Text('100%', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // ── زر Logout العائم ──
          Positioned(
            left: 16,
            top: 16,
            child: LogoutPill(onTap: onLogout),
          ),
        ],
      ),
    );
  }
}