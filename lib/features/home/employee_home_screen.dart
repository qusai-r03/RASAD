import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/current_user_provider.dart';
import '../complaints/complaints_provider.dart';

/// رئيسية الموظف (حسب التصميم).
class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final complaints = ref.watch(complaintsProvider);

    return Scaffold(
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Color(0xFFE3EEF3), shape: BoxShape.circle),
              child: const Icon(Icons.person, size: 22, color: Color(0xFF1E4D5C)),
            ),
            const Spacer(),
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text('${context.tr('hello')} ${user?.firstName ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text('${context.tr('officerRegion')} ${user?.region ?? ''}',
              style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          Row(children: [
            StatCard(
              value: mockStats['done']!,
              label: context.tr('done'),
              icon: Icons.check_box_rounded,
              bg: AppColors.doneBg,
              fg: AppColors.doneFg,
              onTap: () => context.go('/reports?status=done'),
            ),
            const SizedBox(width: 10),
            StatCard(
              value: mockStats['progress']!,
              label: context.tr('inProgress'),
              icon: Icons.schedule,
              bg: AppColors.progressBg,
              fg: AppColors.progressFg,
              onTap: () => context.go('/reports?status=progress'),
            ),
            const SizedBox(width: 10),
            StatCard(
              value: mockStats['new']!,
              label: context.tr('newComplaints'),
              icon: Icons.description,
              bg: AppColors.newBg,
              fg: AppColors.newFg,
              onTap: () => context.go('/reports?status=new'),
            ),
          ]),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/map'),
            icon: const Icon(Icons.map_outlined),
            label: Text(context.tr('viewMap')),
          ),
          const SizedBox(height: 20),
          Text(context.tr('latest'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final c in complaints.take(3))
            ComplaintTile(c, onTap: () => context.push('/complaint/${c.id}')),
        ]),
      ),
    );
  }
}
