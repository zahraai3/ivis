// lib/screens/intro_screen.dart

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../theme/app_theme.dart';
import '../widgets/input_field.dart';

// تعريف شاشة البداية كـ StatefulWidget لأن بها بيانات تتغير (name + phone)
class IntroScreen extends StatefulWidget {
  // دالة يتم تمريرها من خارج الشاشة لاستلام الاسم ورقم الهاتف بعد الضغط على Continue
  final void Function(String name, String phone) onContinue;

  const IntroScreen({super.key, required this.onContinue});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _fullPhone = '';

  @override
  void dispose() {
    // مهم جدًا: تحرير الذاكرة عند إغلاق الشاشة
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // دالة تنفيذ عند الضغط على Continue
  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill name')),
      );
      return;
    }
    widget.onContinue(name, _fullPhone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: AppColors.background),
              ),
              Positioned(
                right: 40,
                bottom: 420,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/nurse.jpg',
                    width: constraints.maxWidth * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'Enter your details to continue',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IntroField(controller: _nameCtrl, hint: 'Nurse Name'),
                      const SizedBox(height: 14),
                      IntlPhoneField(
                        controller: _phoneCtrl,
                        initialCountryCode: 'IQ',//iraq
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMD),
                            borderSide: const BorderSide(
                                color: Color(0xFF1D2B71), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMD),
                            borderSide: const BorderSide(
                                color: AppColors.borderFocused, width: 2),
                          ),
                        ),
                        // كلما يتغير الرقم → نخزن الرقم الكامل (مع الكود)
                        onChanged: (phone) {
                          _fullPhone = phone.completeNumber;
                        },
                      ),
                      const SizedBox(height: 24),
                      // زر Continue
                      SizedBox(
                        height: AppDimensions.buttonHeightLG,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          onPressed: _submit,
                          //------------------
                            // الكود الحقيقي لإرسال بيانات الممرضة للجهاز (معلّق):
                            // try {
                            //   final uri = Uri.parse('$espBaseUrl/intro');
                            //   final res = await http.post(
                            //     uri,
                            //     headers: {'Content-Type': 'application/json'},
                            //     body: jsonEncode({'name': name, 'phone': phone}),
                            //   );
                            //   if (res.statusCode == 200) { ... } else { ... }
                            // } catch (e) { _showMsg('Error: $e'); }
                            // _lastRunning = false → انتقل لإعداد جديد (step -2)
                            // _lastRunning = true  → يعني الجهاز كان شغّال قبل
                            //                        (مثلاً الممرضة خرجت وعادت)
                            //                        فنرجعها مباشرة للمراقبة (step 5)
                          //   if (!mounted) return;
                          //
                          //   },
                          //------------------
                          child: Text('Continue',
                              style: AppTextStyles.buttonLarge),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}