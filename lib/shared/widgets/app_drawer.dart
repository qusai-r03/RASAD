import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/current_user_provider.dart';

/// القائمة الجانبية (زر ☰ في رئيسية الموظف).
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          onTap: () {
            Navigator.pop(context); // يغلق القائمة ثم ينتقل
            onTap();
          },
        );

    return Drawer(
      child: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.primarySoft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CircleAvatar(radius: 28, backgroundColor: Color(0xFFBFDCE8), child: Icon(Icons.person, size: 32, color: Color(0xFF1E4D5C))),
              const SizedBox(height: 10),
              Text(user?.name ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('${context.tr('regionWord')} ${user?.region ?? ''}', style: const TextStyle(color: AppColors.muted)),
            ]),
          ),
          item(Icons.home_outlined, context.tr('navHome'), () => context.go('/home')),
          item(Icons.assignment_outlined, context.tr('navComplaints'), () => context.go('/reports')),
          item(Icons.map_outlined, context.tr('navMap'), () => context.go('/map')),
          item(Icons.person_outline, context.tr('navProfile'), () => context.go('/profile')),
          item(Icons.notifications_none, context.tr('notifications'), () => context.push('/notifications')),
          item(Icons.help_outline, context.tr('help'), () => context.push('/help')),
          const Spacer(),
          const Divider(height: 1),
          item(Icons.logout, context.tr('logout'), () => ref.read(currentUserProvider.notifier).state = null),
        ]),
      ),
    );
  }
}
