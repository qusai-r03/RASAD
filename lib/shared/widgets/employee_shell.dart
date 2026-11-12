import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'employee_bottom_bar.dart';

class EmployeeShell extends StatelessWidget {
  final Widget child;

  const EmployeeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    final selectedIndex = switch (path) {
      '/reports' => 1,
      '/map' => 2,
      '/profile' => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: EmployeeBottomBar(
        selectedIndex: selectedIndex,
        onHome: () => context.go('/dashboard'),
        onReports: () => context.go('/reports'),
        onMap: () => _comingSoon(context),
        onProfile: () => context.go('/profile'),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('خريطة الموظف ستتوفر قريباً')));
  }
}
