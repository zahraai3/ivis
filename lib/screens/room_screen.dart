// lib/screens/room_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons.dart';

class RoomScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onLogout;

  const RoomScreen({
    super.key,
    required this.onContinue,
    required this.onLogout,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _roomCtrl = TextEditingController();

  @override
  void dispose() {
    _roomCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final room = _roomCtrl.text.trim();
  //تحقق من الحقل وصحه معلومات الفيلد
    if (room.isEmpty) {
      _showMsg('Please enter room number');
      return;
    }

    final roomNum = int.tryParse(room);
    if (roomNum == null) {
      _showMsg('Room number must be a number');
      return;
    }

    if (roomNum < 1 || roomNum > 500) {
      _showMsg('Room number must be between 1 and 500');
      return;
    }

    widget.onContinue();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية الشاشة
          Positioned.fill(
            child: Image.asset(
              'assets/images/madbg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // طبقة داكنة
          Positioned.fill(
            child: Container(
              color: AppColors.textPrimary.withOpacity(0.55),
            ),
          ),
          // المحتوى
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // أيقونة المستشفى فوق العنوان
                  const Icon(
                    Icons.local_hospital_rounded,
                    size: 48,
                    color: AppColors.borderFocused,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  //عنوان الشاشه
                  Text(
                    'Room Number',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSM),
                  //وصف مساعد
                  Text(
                    "Enter the patient's room number to continue",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                  TextField(
                    controller: _roomCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. 204',
                      hintStyle: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.4),
                      ),
                      fillColor: AppColors.textOnPrimary.withOpacity(0.1),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD),
                        borderSide: BorderSide(
                          color: AppColors.textOnPrimary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLG),
                  SizedBox(
                    height: AppDimensions.buttonHeightLG,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: Text('Continue',
                          style: AppTextStyles.buttonLarge),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // زر Logout
          Positioned(
            left: 16,
            top: 16,
            child: SafeArea(
              child: LogoutPill(onTap: widget.onLogout),
            ),
          ),
        ],
      ),
    );
  }
}