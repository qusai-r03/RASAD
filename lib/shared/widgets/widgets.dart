import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import 'app_image.dart';

// ------------------------------------------------------------------ helpers

String fmtDate(DateTime d) =>
    '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

String fmtDateTime(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final suffix = d.hour < 12 ? 'ص' : 'م';
  return '${fmtDate(d)} - ${h12.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $suffix';
}

void showSoon(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('soon'))));

({String key, Color bg, Color fg, IconData icon}) statusStyle(ComplaintStatus s) => switch (s) {
      ComplaintStatus.newC => (key: 'statusNew', bg: AppColors.newBg, fg: AppColors.newFg, icon: Icons.error),
      ComplaintStatus.inProgress =>
        (key: 'statusProgress', bg: AppColors.progressBg, fg: AppColors.progressFg, icon: Icons.schedule),
      ComplaintStatus.done => (key: 'statusDone', bg: AppColors.doneBg, fg: AppColors.doneFg, icon: Icons.check_circle),
    };

// ------------------------------------------------------------------ chips

class StatusChip extends StatelessWidget {
  final ComplaintStatus status;
  final bool withIcon;
  const StatusChip(this.status, {super.key, this.withIcon = false});

  @override
  Widget build(BuildContext context) {
    final s = statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (withIcon) ...[Icon(s.icon, size: 13, color: s.fg), const SizedBox(width: 4)],
        Text(context.tr(s.key), style: TextStyle(color: s.fg, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class PriorityChip extends StatelessWidget {
  final Priority priority;
  const PriorityChip(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final (key, bg, fg) = switch (priority) {
      Priority.high => ('priorityHigh', AppColors.newBg, AppColors.newFg),
      Priority.medium => ('priorityMedium', AppColors.progressBg, AppColors.progressFg),
      Priority.low => ('priorityLow', AppColors.doneBg, AppColors.doneFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 8, color: fg),
        const SizedBox(width: 5),
        Text(context.tr(key), style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ------------------------------------------------------------------ cards

/// بطاقة بيضاء بعنوان وأيقونة خضراء.
class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppDecor.card(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

/// رابط أخضر مع سهم («عرض التفاصيل ‹»).
class LinkRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const LinkRow(this.label, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 2),
            Icon(rtl ? Icons.chevron_left : Icons.chevron_right, color: AppColors.primary, size: 20),
          ]),
        ),
      ),
    );
  }
}

/// بطاقة رقم + تسمية. [compact] = الرقم بجانب الأيقونة (رئيسية المواطن)،
/// وإلا الأيقونة فوق الرقم (رئيسية الموظف).
class StatCard extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color bg, fg;
  final VoidCallback? onTap;
  final bool compact;
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final number = Text('$value', style: TextStyle(fontSize: compact ? 22 : 24, fontWeight: FontWeight.w800));
    final caption = Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted));
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: compact ? 10 : 14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: compact
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(icon, color: fg, size: 22),
                    const SizedBox(width: 6),
                    number,
                  ]),
                  const SizedBox(height: 2),
                  caption,
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, color: fg, size: 28),
                  const SizedBox(height: 6),
                  number,
                  caption,
                ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ complaints

/// صورة مصغّرة للشكوى (الصورة الحقيقية إن وُجدت في assets وإلا بديلة).
class ComplaintThumb extends StatelessWidget {
  final Complaint c;
  final double width, height, radius;
  const ComplaintThumb(this.c, {super.key, this.width = 64, this.height = 64, this.radius = 12});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: width,
          height: height,
          child: c.localImagePath != null
              ? Image.file(
                  File(c.localImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ImagePlaceholder(),
                )
              : AppImage(asset: c.imageAsset, fallback: const ImagePlaceholder()),
        ),
      );
}

class ComplaintTile extends StatelessWidget {
  final Complaint c;
  final VoidCallback? onTap;
  const ComplaintTile(this.c, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppDecor.card(radius: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('#${c.id}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 6),
                Row(children: [
                  StatusChip(c.status),
                  const Spacer(),
                  Text(fmtDate(c.date), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ]),
              ]),
            ),
            const SizedBox(width: 10),
            ComplaintThumb(c),
            Icon(rtl ? Icons.chevron_left : Icons.chevron_right, size: 20, color: AppColors.muted),
          ]),
        ),
      ),
    );
  }
}
