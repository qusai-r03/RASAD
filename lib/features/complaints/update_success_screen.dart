import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'complaints_provider.dart';

/// شاشة «تم تحديث حالة الشكوى بنجاح».
class UpdateSuccessScreen extends ConsumerWidget {
  final String id;
  const UpdateSuccessScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(complaintByIdProvider(id));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(context.tr('updatedOk'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 6),
            Text(context.tr('savedOk'), style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 22),
            if (c != null)
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
                  StatusChip(c.status),
                ]),
              ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.pop(), // يرجع إلى التفاصيل (الشاشة السابقة في المكدّس)
              child: Text(context.tr('backToDetails')),
            ),
          ]),
        ),
      ),
    );
  }
}
