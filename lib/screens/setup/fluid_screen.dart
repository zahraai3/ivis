// lib/screens/setup/fluid_screen.dart

import 'package:flutter/material.dart';
import '../../data/iv_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

class FluidScreen extends StatelessWidget {
  final int groupIndex;
  final void Function(String fluid, int itemNum) onSelect;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const FluidScreen({
    super.key,
    required this.groupIndex,
    required this.onSelect,
    required this.onBack,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final group = kFluidGroups[groupIndex];

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      'Fluid Type',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    // badge يعرض اسم المجموعة المختارة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMD,
                        vertical: AppDimensions.spaceSM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull),
                      ),
                      child: Text(
                        group.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceLG),
                    // ── قائمة أنواع السوائل داخل المجموعة المختارة ──
                    Expanded(
                      child: ListView(
                        children: [
                          for (final item in group.items)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.spaceMD,
                              ),
                              child: BigPillButton(
                                text: item,
                                onTap: () => onSelect(
                                  item,
                                  group.items.indexOf(item) + 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    BottomBar(
                      showBack: true,
                      showSend: false,
                      onBack: onBack,
                      onSend: () {},
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