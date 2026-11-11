import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية RASD الخضراء.
class AppColors {
  static const primary = Color.fromARGB(255, 15, 74, 122);
  static const primaryDark = Color.fromARGB(255, 15, 74, 122);
  static const primarySoft = Color(0xFFE4F3E9);
  static const bg = Color(0xFFF5F8F6);
  static const border = Color(0xFFE6ECE8);
  static const text = Color(0xFF14231A);
  static const muted = Color(0xFF6B7A70);
  static const sky = Color(0xFFBBD6EA);

  static const newBg = Color(0xFFFFE6E8);
  static const newFg = Color(0xFFE0283C);
  static const progressBg = Color(0xFFFFF1CC);
  static const progressFg = Color(0xFFE09A00);
  static const doneBg = Color(0xFFDDF3E4);
  static const doneFg = Color(0xFF1B9A47);
}

class AppDecor {
  static BoxDecoration card({Color color = Colors.white, double radius = 18}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  /// حقل إدخال بحدود خضراء عند التركيز (يُستعمل بدل inputDecorationTheme لتفادي اختلاف الإصدارات).
  static InputDecoration input({String? hint, IconData? icon, Widget? suffix}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      prefixIcon: icon == null ? null : Icon(icon, color: AppColors.muted),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: b(AppColors.border),
      enabledBorder: b(AppColors.border),
      focusedBorder: b(AppColors.primary, 1.6),
    );
  }
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, surface: AppColors.bg),
      scaffoldBackgroundColor: AppColors.bg,
    );
    final styled = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text);
    // عنوان الـ AppBar (Material 3) يستعمل titleLarge: نصغّره ونثقّله لمطابقة التصميم
    // دون استعمال appBarTheme (تغيّر نوعه بين إصدارات Flutter).
    final tt = styled.copyWith(titleLarge: styled.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w700));

    return base.copyWith(
      textTheme: tt,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
