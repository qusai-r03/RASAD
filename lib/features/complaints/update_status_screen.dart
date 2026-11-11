import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/photo_box.dart';
import '../../shared/widgets/widgets.dart';
import 'complaints_provider.dart';

/// تحديث حالة الشكوى (للموظف). حالياً يحدّث البيانات الوهمية في الذاكرة فقط.
class UpdateStatusScreen extends ConsumerStatefulWidget {
  final String id;
  const UpdateStatusScreen({super.key, required this.id});

  @override
  ConsumerState<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends ConsumerState<UpdateStatusScreen> {
  ComplaintStatus? _selected;
  String? _fix;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  static const _labels = {
    ComplaintStatus.newC: 'statusWaiting',
    ComplaintStatus.inProgress: 'statusProgress',
    ComplaintStatus.done: 'statusDone',
  };

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(complaintByIdProvider(widget.id));
    if (c == null) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(context.tr('updateTitle'))),
        body: Center(child: Text(context.tr('notFound'))),
      );
    }
    final selected = _selected ?? c.status;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('updateTitle'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: AppDecor.card(radius: 14),
          child: Row(children: [
            ComplaintThumb(c),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('#${c.id}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(c.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        Text(context.tr('newStatus'), style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final s in ComplaintStatus.values)
          _StatusOption(
            status: s,
            label: context.tr(_labels[s]!),
            selected: selected == s,
            onTap: () => setState(() => _selected = s),
          ),
        const SizedBox(height: 14),
        Text(context.tr('noteOptional'), style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextField(
          controller: _note,
          maxLines: 4,
          decoration: AppDecor.input(hint: context.tr('noteHint')),
        ),
        const SizedBox(height: 14),
        Text(context.tr('addPhotoOptional'), style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        PhotoBox(
          path: _fix,
          label: context.tr('choosePhoto'),
          onPick: () async {
            final p = await pickPhoto(context);
            if (p != null) setState(() => _fix = p);
          },
          onRemove: () => setState(() => _fix = null),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: () {
              final note = _note.text.trim();
              ref
                  .read(complaintsProvider.notifier)
                  .updateStatus(c.id, selected, note: note.isEmpty ? null : note, fixImagePath: _fix);
              context.pushReplacement('/complaint-updated/${c.id}');
            },
            child: Text(context.tr('saveUpdate')),
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final ComplaintStatus status;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StatusOption({required this.status, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = statusStyle(status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? s.bg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? s.fg : AppColors.border, width: selected ? 1.6 : 1),
          ),
          child: Row(children: [
            Icon(s.icon, color: s.fg, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
          ]),
        ),
      ),
    );
  }
}
