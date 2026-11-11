import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/current_user_provider.dart';
import 'widgets.dart';

/// فهارس الفروع في الـ ShellRoute: 0 الرئيسية · 1 الشكاوى · 2 الخريطة · 3 الملف الشخصي
///
/// المواطن:  الرئيسية – الخريطة – [+] – شكاواي – المزيد
/// الموظف:   الرئيسية – الشكاوى – الخريطة – الملف الشخصي
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProvider)?.role ?? UserRole.citizen;
    final cur = shell.currentIndex;
    void go(int i) => shell.goBranch(i, initialLocation: i == cur);

    Widget item(int branch, IconData icon, IconData selIcon, String labelKey) => _NavItem(
          icon: icon,
          selectedIcon: selIcon,
          label: context.tr(labelKey),
          selected: cur == branch,
          onTap: () => go(branch),
        );

    final home = item(0, Icons.home_outlined, Icons.home_rounded, 'navHome');
    final map = item(2, Icons.map_outlined, Icons.map_rounded, 'navMap');

    return Scaffold(
      body: shell,
      bottomNavigationBar: role == UserRole.citizen
          ? _FloatingBar(
              onFab: () => context.push('/new-complaint'),
              items: [
                home,
                map,
                const SizedBox(width: 76),
                item(1, Icons.assignment_outlined, Icons.assignment_rounded, 'navMine'),
                item(3, Icons.grid_view_outlined, Icons.grid_view_rounded, 'navMore'),
              ],
            )
          : _FloatingBar(
              items: [
                home,
                item(1, Icons.assignment_outlined, Icons.assignment_rounded, 'navComplaints'),
                map,
                item(3, Icons.person_outline, Icons.person, 'navProfile'),
              ],
            ),
    );
  }
}

class _FloatingBar extends StatelessWidget {
  final List<Widget> items;
  final VoidCallback? onFab;
  const _FloatingBar({required this.items, this.onFab});

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SizedBox(
          height: onFab == null ? 84 : 98,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              height: 68,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 4))],
                ),
                child: Row(children: items),
              ),
            ),
            if (onFab != null)
              Positioned(top: 0, left: 0, right: 0, child: Center(child: _Fab(onTap: onFab!))),
          ]),
        ),
      );
}

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF071B33)],
            ),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [BoxShadow(color: Color(0x4D0F4A7A), blurRadius: 14, offset: Offset(0, 5))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 34),
        ),
      );
}

class _NavItem extends StatelessWidget {
  final IconData icon, selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: selected
              ? BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(18))
              : null,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color)),
          ]),
        ),
      ),
    );
  }
}
