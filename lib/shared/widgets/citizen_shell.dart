import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'citizen_bottom_bar.dart';

class CitizenShell extends StatelessWidget {
  final Widget child;

  const CitizenShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    final selectedIndex = switch (path) {
      '/reports' => 2,
      '/profile' => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: CitizenBottomBar(
        selectedIndex: selectedIndex,
        onHome: () => context.go('/dashboard'),
        onReports: () => context.go('/reports'),
        onMap: () => _comingSoon(context),
        onAdd: () => _comingSoon(context),
        onProfile: () => context.go('/profile'),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('هذه الميزة ستتوفر قريباً')));
  }
}
