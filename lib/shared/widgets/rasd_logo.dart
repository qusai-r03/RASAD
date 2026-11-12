import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'app_image.dart';

/// شعار RASD: دبوس موقع بداخله مبانٍ + «رصد / RASD».
/// عند وجود assets/images/logo.png يُستخدم بدل الرسم.
class RasdLogo extends StatelessWidget {
  final double size;
  final bool light; // على خلفية داكنة
  const RasdLogo({super.key, this.size = 44, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : AppColors.primary;
    return SizedBox(
      height: size,
      child: AppImage(
        asset: AppAssets.logo,
        fit: BoxFit.contain,
        fallback: Row(mainAxisSize: MainAxisSize.min, children: [
          Stack(alignment: Alignment.center, children: [
            Icon(Icons.location_on, size: size, color: color),
            Padding(
              padding: EdgeInsets.only(bottom: size * .16),
              child: Icon(Icons.apartment_rounded, size: size * .38, color: light ? AppColors.primary : Colors.white),
            ),
          ]),
          const SizedBox(width: 6),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('رصد', style: TextStyle(fontSize: size * .5, fontWeight: FontWeight.w800, color: color, height: 1)),
            Text('RASD',
                style: TextStyle(
                    fontSize: size * .36, fontWeight: FontWeight.w800, letterSpacing: 2, color: color, height: 1.1)),
          ]),
        ]),
      ),
    );
  }
}
