import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'app_image.dart';

/// رسومات بديلة تُستبدل تلقائياً عند وضع الصور الأصلية في assets/images.

/// خط سماء المدينة (أعلى رئيسية المواطن).
class SkylineArt extends StatelessWidget {
  const SkylineArt({super.key});

  @override
  Widget build(BuildContext context) => AppImage(
        asset: AppAssets.skyline,
        fit: BoxFit.contain,
        fallback: ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, Colors.transparent],
          ).createShader(r),
          blendMode: BlendMode.dstIn,
          child: CustomPaint(painter: _SkylinePainter(), size: Size.infinite),
        ),
      );
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const heights = [.45, .72, .55, .92, .6, .78, .42, .66];
    final body = Paint()..color = AppColors.sky.withValues(alpha: .8);
    final win = Paint()..color = Colors.white.withValues(alpha: .65);
    final w = size.width / heights.length;
    for (var i = 0; i < heights.length; i++) {
      final h = size.height * heights[i];
      final rect = Rect.fromLTWH(i * w + 2, size.height - h, w - 4, h);
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
        body,
      );
      for (double y = rect.top + 8; y < rect.bottom - 6; y += 12) {
        canvas.drawRect(Rect.fromLTWH(rect.left + 5, y, 4, 5), win);
        canvas.drawRect(Rect.fromLTWH(rect.right - 9, y, 4, 5), win);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// صورة بطاقة «لاحظت مشكلة في الشارع؟».
class HeroArt extends StatelessWidget {
  const HeroArt({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB7CBB9), Color(0xFF7F9283)],
          ),
        ),
        child: const Stack(alignment: Alignment.center, children: [
          Positioned(bottom: 10, child: Icon(Icons.horizontal_rule_rounded, size: 70, color: Colors.white38)),
          Icon(Icons.warning_amber_rounded, size: 54, color: Color(0xFFFF8A1F)),
        ]),
      );
}

/// صورة بطاقة «فحص الطريق».
class RoadArt extends StatelessWidget {
  const RoadArt({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFEAF6EE), Color(0xFFCBE8D5)],
          ),
        ),
        child: const Stack(alignment: Alignment.center, children: [
          Icon(Icons.alt_route_rounded, size: 56, color: AppColors.primary),
          Positioned(top: 8, right: 14, child: Icon(Icons.location_on, size: 30, color: AppColors.primaryDark)),
        ]),
      );
}
