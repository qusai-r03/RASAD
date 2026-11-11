import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/current_user_provider.dart';

/// صفحة الملف الشخصي المشتركة (مواطن + موظف) حسب التصميم.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    Widget item(IconData icon, String label, String route) => ListTile(
          leading: Icon(icon, color: AppColors.muted),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Icon(rtl ? Icons.chevron_left : Icons.chevron_right, size: 20, color: AppColors.muted),
          onTap: () => context.push(route),
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: Text(context.tr('profile')),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            const CircleAvatar(
              radius: 38,
              backgroundColor: Color(0xFFBFDCE8),
              child: Icon(Icons.person, size: 46, color: Color(0xFF1E4D5C)),
            ),
            const SizedBox(height: 10),
            Text(user?.name ?? '', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            Text(context.tr(user?.role == UserRole.employee ? 'employee' : 'citizen'),
                style: const TextStyle(color: AppColors.muted)),
            if (user != null)
              Text('${context.tr('regionWord')} ${user.region}', style: const TextStyle(color: AppColors.muted)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppDecor.card(radius: 16),
          child: Column(children: [
            item(Icons.person_outline, context.tr('editData'), '/edit-profile'),
            const Divider(height: 1),
            item(Icons.lock_outline, context.tr('changePass'), '/change-password'),
            const Divider(height: 1),
            item(Icons.notifications_none, context.tr('notifications'), '/notifications'),
            const Divider(height: 1),
            item(Icons.help_outline, context.tr('help'), '/help'),
          ]),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.newFg,
            backgroundColor: AppColors.newBg.withValues(alpha: .4),
            side: const BorderSide(color: AppColors.newFg),
          ),
          onPressed: () => ref.read(currentUserProvider.notifier).state = null, // TODO(Auth): auth.signOut()
          icon: const Icon(Icons.logout),
          label: Text(context.tr('logout')),
        ),
      ]),
    );
  }
}
