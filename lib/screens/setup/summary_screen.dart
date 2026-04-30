// lib/screens/setup/summary_screen.dart

import 'package:flutter/material.dart';
import '../../data/iv_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/header.dart';

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
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingH,
                  vertical: AppDimensions.screenPaddingV,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Header(title1: 'DONE', title2: 'SUMMARY'),
                    const SizedBox(height: 25),
                    // بطاقة بيضاء تعرض ملخص كل ما اختارته الممرضة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capacity: $capacityMl mL',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Group: ${kFluidGroups[groupIndex].title}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Fluid: $fluid',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // عنوان الجهاز — مفيد للتشخيص في حالة مشاكل الاتصال
                          Text(
                            'ESP: $espBaseUrl',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    BottomBar(
                      showBack: true,
                      showSend: true,
                      onBack: onBack,
                      onSend: isSending ? () {} : onSend,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}