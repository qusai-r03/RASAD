import 'package:flutter/material.dart';

/// أسماء ملفات الصور المتوقعة داخل assets/images/.
/// ضع الملف بنفس الاسم فيظهر تلقائياً بدل الصورة البديلة، بدون تعديل الكود.
class AppAssets {
  static const logo = 'assets/images/logo.png';
  static const skyline = 'assets/images/city_skyline.jpeg';
  static const hero = 'assets/images/hero_pothole.png';
  static const road = 'assets/images/road_check.png';
  static const loginBg = 'assets/images/login_bg.jpg';
}

/// يعرض صورة من assets، وإن لم تتوفر يعرض [fallback].
class AppImage extends StatelessWidget {
  final String? asset;
  final Widget fallback;
  final BoxFit fit;
  const AppImage(
      {super.key,
      required this.asset,
      required this.fallback,
      this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final a = asset;
    if (a == null) return fallback;
    return Image.asset(a, fit: fit, errorBuilder: (_, __, ___) => fallback);
  }
}

/// صورة بديلة (تدرّج رمادي بلون الإسفلت + أيقونة).
class ImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  const ImagePlaceholder(
      {super.key, this.icon = Icons.image_outlined, this.iconSize = 26});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCFCBC4), Color(0xFF98938A)],
          ),
        ),
        child: Center(child: Icon(icon, size: iconSize, color: Colors.white70)),
      );
}
