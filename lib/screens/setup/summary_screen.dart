// lib/screens/setup/summary_screen.dart
// lib/screens/setup/summary_screen.dart

import 'package:flutter/material.dart';
import '../../data/iv_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

class SummaryScreen extends StatelessWidget {
  final int capacityMl;
  final int groupIndex;
  final String fluid;
  final String espBaseUrl;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const SummaryScreen({
    super.key,
    required this.capacityMl,
    required this.groupIndex,
    required this.fluid,
    required this.espBaseUrl,
    required this.isSending,
    required this.onSend,
    required this.onBack,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── خلفية gradient متطابقة مع باقي شاشات الإعداد ──
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.screenPaddingV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),

                  // ── العنوان ──
                  _buildHeader(),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── البطاقة الرئيسية ──
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildSummaryCard(),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // ── شريط الأزرار السفلي ──
                  BottomBar(
                    showBack: true,
                    showSend: true,
                    onBack: onBack,
                    onSend: isSending ? () {} : onSend,
                  ),
                  const SizedBox(height: AppDimensions.spaceSM),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── بناء العنوان ──
  Widget _buildHeader() {
    return Column(
      children: [
        // أيقونة دائرية
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.textOnPrimary,
            size: 34,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),

        // العنوان
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontSize: 26),
            children: [
              TextSpan(
                text: 'Setup ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'Summary',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          'Review your selections before sending',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── بناء بطاقة الملخص ──
  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
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
        children: [
          // ── السعة ──
          _buildRow(
            icon: Icons.water_drop_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.accentLight,
            label: 'Capacity',
            value: '$capacityMl mL',
            showDivider: true,
          ),

          // ── المجموعة ──
          _buildRow(
            icon: Icons.category_rounded,
            iconColor: AppColors.secondary,
            iconBg: AppColors.successLight,
            label: 'Fluid Group',
            value: kFluidGroups[groupIndex].title,
            showDivider: true,
          ),

          // ── نوع السائل ──
          _buildRow(
            icon: Icons.science_rounded,
            iconColor: AppColors.warning,
            iconBg: AppColors.warningLight,
            label: 'Fluid Type',
            value: fluid,
            showDivider: true,
          ),

          // ── عنوان الجهاز ──
          // مفيد للتشخيص في حالة مشاكل الاتصال
          _buildRow(
            icon: Icons.wifi_rounded,
            iconColor: AppColors.textSecondary,
            iconBg: AppColors.surfaceVariant,
            label: 'ESP Address',
            value: espBaseUrl,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // ── صف بيانات واحد داخل البطاقة ──
  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
            vertical: AppDimensions.spaceMD,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة ملونة
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppDimensions.spaceMD),

              // النص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // فاصل بين الصفوف
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}