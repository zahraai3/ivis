// lib/screens/setup/group_screen.dart

import 'package:flutter/material.dart';
import '../../data/iv_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

class GroupScreen extends StatelessWidget {
  final void Function(int groupIndex) onSelect;
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const GroupScreen({
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
                    const SizedBox(height: 45),
                    Text(
                      'Select Fluid Group',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Text(
                      'Choose the fluid category',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXL),
                    Expanded(
                      child: ListView(
                        children: kFluidGroups
                            .asMap()
                            .entries
                            .map((entry) =>
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.spaceMD,
                              ),
                              child: BigPillButton(
                                text: entry.value.title,
                                onTap: () => onSelect(entry.key),
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