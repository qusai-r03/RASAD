import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/current_user_provider.dart';
import 'complaints_provider.dart';
/// تفاصيل الشكوى. زر «تحديث الحالة» يظهر للموظف فقط.
class ComplaintDetailScreen extends ConsumerWidget {
  final String id;
  const ComplaintDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(complaintByIdProvider(id));
    final role = ref.watch(currentUserProvider)?.role;

    if (c == null) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(context.tr('detailsTitle'))),
        body: Center(child: Text(context.tr('notFound'))),
      );
    }

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('detailsTitle'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ComplaintThumb(c, width: double.infinity, height: 200, radius: 16),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecor.card(),
          child: Column(children: [
            Row(children: [
              Text('#${c.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              StatusChip(c.status),
            ]),
            const Divider(height: 24),
            _InfoRow(icon: Icons.construction_rounded, label: context.tr('category'), value: c.title),
            _InfoRow(
              icon: Icons.auto_awesome_rounded,
              label: context.tr('aiResult'),
              value: c.aiConfidence == 0 ? context.tr('analyzing') : '${c.aiLabel} (${(c.aiConfidence * 100).round()}%)',
            ),
            _InfoRow(icon: Icons.flag_rounded, label: context.tr('priority'), trailing: PriorityChip(c.priority)),
            _InfoRow(icon: Icons.location_on_outlined, label: context.tr('location'), value: c.location),
            _InfoRow(icon: Icons.event_outlined, label: context.tr('dateTime'), value: fmtDateTime(c.date)),
            _InfoRow(icon: Icons.notes_rounded, label: context.tr('description'), value: c.description, last: c.note == null),
            if (c.note != null)
              _InfoRow(icon: Icons.sticky_note_2_outlined, label: context.tr('noteOptional'), value: c.note!, last: true),
          ]),
        ),
        if (c.fixImagePath != null) ...[
          const SizedBox(height: 14),
          Text(context.tr('fixPhoto'), style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(c.fixImagePath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
             errorBuilder: (_, __, ___) => Container(
  height: 180,
  width: double.infinity,
  color: Colors.grey.shade200,
  child: const Icon(
    Icons.broken_image_outlined,
    size: 50,
    color: Colors.grey,
  ),
),
            ),
          ),
        ],
      ]),
      bottomNavigationBar: role == UserRole.employee
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  onPressed: () => context.push('/complaint-update/${c.id}'),
                  child: Text(context.tr('updateStatusBtn')),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool last;
  const _InfoRow({required this.icon, required this.label, this.value, this.trailing, this.last = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 2),
              if (value != null) Text(value!, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
              if (trailing != null) Padding(padding: const EdgeInsets.only(top: 2), child: trailing!),
            ]),
          ),
        ]),
      );
}
