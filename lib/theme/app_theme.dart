// ============================================================
// app_theme.dart — ثيم التطبيق الكامل
// التطبيق: Codey — نظام مراقبة السيروم الوريدي
// ============================================================
// كيفية الاستخدام:
//   1. ضع هذا الملف في مجلد lib/theme/app_theme.dart
//   2. في main.dart أضف: import 'theme/app_theme.dart';
//   3. في MaterialApp أضف: theme: AppTheme.themeData,
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// الألوان الأساسية
// ============================================================
class AppColors {

  // ── Primary — أزرق طبي حديث ──
  static const Color primary        = Color(0xFF2563EB);
  static const Color primaryLight   = Color(0xFF3B82F6); // نسخة أفتح للـ hover
  static const Color primaryDark    = Color(0xFF1D4ED8); // نسخة أغمق للـ pressed

  // ── Secondary — أخضر مهدئ ──
  static const Color secondary      = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark  = Color(0xFF059669);

  // ── Background & Surface ──
  static const Color background     = Color(0xFFF9FAFB); // خلفية التطبيق
  static const Color surface        = Color(0xFFFFFFFF); // الكروت والبطاقات
  static const Color surfaceVariant = Color(0xFFF3F4F6); // كروت ثانوية أو inputs

  // ── Accent — سماوي خفيف ──
  static const Color accent         = Color(0xFF38BDF8);
  static const Color accentLight    = Color(0xFFBAE6FD);

  // ── النصوص ──
  static const Color textPrimary    = Color(0xFF111827); // نصوص رئيسية غامقة
  static const Color textSecondary  = Color(0xFF6B7280); // نصوص وصفية خفيفة
  static const Color textOnPrimary  = Color(0xFFFFFFFF); // نص فوق الأزرار الملونة
  static const Color textDisabled   = Color(0xFF9CA3AF); // نص معطّل

  // ── الحالات الطبية (مهم!) ──
  static const Color success        = Color(0xFF22C55E); // ✅ ناجح / طبيعي
  static const Color successLight   = Color(0xFFDCFCE7); // خلفية بطاقة النجاح
  static const Color warning        = Color(0xFFF59E0B); // ⚠️ تحذير / أقل من 50%
  static const Color warningLight   = Color(0xFFFEF3C7); // خلفية بطاقة التحذير
  static const Color error          = Color(0xFFEF4444); // 🔴 خطر / أقل من 10%
  static const Color errorLight     = Color(0xFFFEE2E2); // خلفية بطاقة الخطأ

  // ── الحدود والفواصل ──
  static const Color border         = Color(0xFFE5E7EB);
  static const Color borderFocused  = Color(0xFF2563EB); // حدود عند التركيز

  // ── الظلال ──
  static const Color shadow         = Color(0x1A000000); // ظل خفيف 10% أسود

  // ── Gradient الرئيسي (بديل الـ gradient القديم) ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
  );

  // ── Gradient للخلفيات الشاشات ──
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)], // أزرق فاتح جداً
  );
}

// ============================================================
// أنماط النصوص

// ============================================================
class AppTextStyles {

  // ── العناوين الكبيرة ──
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800, // ExtraBold
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // ── عناوين الشاشات (بديل _Header الحالي) ──
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
  );

  // ── نصوص الأزرار ──
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // ── نصوص الجسم ──
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── نصوص ثانوية ووصفية ──
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  // ── الرقم الكبير في شاشة المراقبة (%) ──
  static const TextStyle monitorDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w800,
    letterSpacing: -2,
    height: 1.0,
    // اللون يتحدد ديناميكياً حسب النسبة — لا نضعه هنا
  );

  // ── نص صغير لـ ESP / التشخيص ──
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textDisabled,
    letterSpacing: 0.3,
  );
}

// ============================================================
// ثوابت التصميم (Spacing, Radius, Shadows)
// ============================================================
class AppDimensions {

  // ── المسافات ──
  static const double spaceXS  = 4.0;
  static const double spaceSM  = 8.0;
  static const double spaceMD  = 16.0;
  static const double spaceLG  = 24.0;
  static const double spaceXL  = 32.0;
  static const double space2XL = 48.0;

  // ── الـ Padding الأفقي للشاشات ──
  static const double screenPaddingH = 20.0;
  static const double screenPaddingV = 16.0;

  // ── زوايا الكروت والأزرار ──
  static const double radiusSM   = 8.0;
  static const double radiusMD   = 12.0;
  static const double radiusLG   = 16.0;
  static const double radiusXL   = 20.0;
  static const double radiusFull = 999.0; // للأزرار الـ Pill

  // ── ارتفاعات الأزرار ──
  static const double buttonHeightLG = 56.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightSM = 40.0;

  // ── ارتفاعات حقول الإدخال ──
  static const double inputHeight = 56.0;
}

// ============================================================
// الظلال (Shadows)
// ============================================================
class AppShadows {

  // ظل خفيف للكروت
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ظل متوسط للأزرار
  static List<BoxShadow> get button => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ظل قوي للعناصر العائمة
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// ============================================================
// الـ ThemeData الكامل
// ============================================================
class AppTheme {

  // ── الثيم الرئيسي ──
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),

      // ── نظام الألوان ──
      colorScheme: const ColorScheme.light(
        primary:          AppColors.primary,
        onPrimary:        AppColors.textOnPrimary,
        primaryContainer: AppColors.accentLight,
        secondary:        AppColors.secondary,
        onSecondary:      AppColors.textOnPrimary,
        surface:          AppColors.surface,
        onSurface:        AppColors.textPrimary,
        error:            AppColors.error,
        onError:          AppColors.textOnPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.primary,
        foregroundColor:  AppColors.textOnPrimary,
        elevation:        0,
        centerTitle:      true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:           Colors.transparent,
          statusBarIconBrightness:  Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily:   'Inter',
          fontSize:     18,
          fontWeight:   FontWeight.w700,
          color:        AppColors.textOnPrimary,
        ),
      ),

      // ── الأزرار الرئيسية ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.primary,
          foregroundColor:  AppColors.textOnPrimary,
          minimumSize:      const Size(double.infinity, AppDimensions.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          elevation:        0,
          textStyle:        AppTextStyles.buttonLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
            vertical:   AppDimensions.spaceMD,
          ),
        ),
      ),

      // ── الأزرار المحددة (Outlined) ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:  AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize:      const Size(double.infinity, AppDimensions.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.primary),
        ),
      ),

      // ── الأزرار النصية ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:  AppColors.primary,
          textStyle:        AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),

      // ── حقول الإدخال ──
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical:   AppDimensions.spaceMD,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
        // الحالة الطبيعية
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        // عند التركيز
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.borderFocused, width: 2),
        ),
        // عند الخطأ
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.labelLarge,
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // ── الكروت ──
      cardTheme: CardThemeData(
        color:         AppColors.surface,
        elevation:     0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical:   AppDimensions.spaceSM,
        ),
      ),

      // ── الـ Divider ──
      dividerTheme: const DividerThemeData(
        color:     AppColors.border,
        thickness: 1,
        space:     AppDimensions.spaceMD,
      ),

      // ── الـ SnackBar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── الـ Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor:  AppColors.surface,
        elevation:        0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        titleTextStyle:   AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ── الـ Progress Indicator ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:                AppColors.primary,
        linearTrackColor:     AppColors.accentLight,
        circularTrackColor:   AppColors.accentLight,
      ),

      // ── نظام النصوص الكامل ──
      // textTheme: const TextTheme(
      //   displayLarge:   AppTextStyles.displayLarge,
      //   displayMedium:  AppTextStyles.displayMedium,
      //   headlineLarge:  AppTextStyles.headlineLarge,
      //   headlineMedium: AppTextStyles.headlineMedium,
      //   headlineSmall:  AppTextStyles.headlineSmall,
      //   bodyLarge:      AppTextStyles.bodyLarge,
      //   bodyMedium:     AppTextStyles.bodyMedium,
      //   bodySmall:      AppTextStyles.bodySmall,
      //   labelLarge:     AppTextStyles.labelLarge,
      //   labelMedium:    AppTextStyles.labelMedium,
      // ),
    );
  }
}

// ============================================================
// دوال مساعدة للحالات الطبية
// ============================================================
// هذه الدوال تستخدم في شاشة المراقبة عشان تحدد اللون
// حسب نسبة السيروم المتبقية
class IVStatusHelper {

  /// لون الـ % حسب نسبة السيروم
  static Color percentColor(double percent) {
    if (percent <= 10) return AppColors.error;    // 🔴 خطر
    if (percent < 50)  return AppColors.warning;  // 🟡 تحذير
    return AppColors.success;                      // 🟢 طبيعي
  }

  /// لون الخلفية الفاتح حسب النسبة (للكروت)
  static Color percentBgColor(double percent) {
    if (percent <= 10) return AppColors.errorLight;
    if (percent < 50)  return AppColors.warningLight;
    return AppColors.successLight;
  }

  /// نص الحالة حسب النسبة
  static String percentLabel(double percent) {
    if (percent <= 10) return 'Critical — Replace Soon';
    if (percent < 50)  return 'Monitor Closely';
    return 'Normal';
  }

  /// أيقونة الحالة حسب النسبة
  static IconData percentIcon(double percent) {
    if (percent <= 10) return Icons.warning_rounded;
    if (percent < 50)  return Icons.info_rounded;
    return Icons.check_circle_rounded;
  }
}