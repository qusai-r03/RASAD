import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// يلتقط صورة بالكاميرا ثم يرجع مسارها (أو null عند الإلغاء/الخطأ).
/// TODO(DB): عند ربط Firebase Storage يُرفع الملف ويُحفظ الرابط بدل المسار المحلي.
Future<String?> pickPhoto(BuildContext context) async {
  try {
    final file = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1600, imageQuality: 85);
    return file?.path;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('photoError'))));
    }
    return null;
  }
}

/// صندوق إضافة صورة (منقّط) أو معاينة الصورة المختارة مع زر حذف.
class PhotoBox extends StatelessWidget {
  final String? path;
  final String label;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  const PhotoBox({super.key, required this.path, required this.label, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p != null) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(p),
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 170,
              color: AppColors.border,
              child: const Icon(Icons.broken_image_outlined, color: AppColors.muted),
            ),
          ),
        ),
        PositionedDirectional(
          top: 8,
          end: 8,
          child: InkWell(
            onTap: onRemove,
            child: const CircleAvatar(radius: 16, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 18, color: Colors.white)),
          ),
        ),
      ]);
    }
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: CustomPaint(
        painter: const _DashedRRectPainter(AppColors.primary),
        child: SizedBox(
          height: 92,
          width: double.infinity,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  const _DashedRRectPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)));
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) => old.color != color;
}
