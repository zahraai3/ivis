import 'package:flutter/material.dart';
import '../../data/iv_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

class CapacityScreen extends StatelessWidget {
  final void Function(int ml) onSelect;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const CapacityScreen({
    super.key,
    required this.onSelect,
    required this.onBack,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية gradient
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 140),
                    Text(
                      'Select Capacity',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Text(
                      'Choose the IV bag size',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXL),
                    Expanded(
                      child: ListView(
                        children: kCapacities.map((cap) =>
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.spaceMD,
                              ),
                              child: BigPillButton(
                                text: cap.label,
                                onTap: () => onSelect(cap.ml),
                              ),
                            ),
                        ).toList(),
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