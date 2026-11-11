import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_role.dart';
import '../services/auth_service.dart';
import '../../app/router.dart';

class RoleDashboard extends StatelessWidget {
  final UserRole role;

  const RoleDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.citizen:
        return const _TemporaryDashboard(
          title: 'Citizen Home',
          description: 'Welcome to RASD Citizen Dashboard',
          icon: Icons.person,
        );

      case UserRole.employee:
        return const _TemporaryDashboard(
          title: 'Employee Home',
          description: 'Welcome to RASD Municipality Dashboard',
          icon: Icons.business,
        );
    }
  }
}

class _TemporaryDashboard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _TemporaryDashboard({
    required this.title,
    required this.description,
    required this.icon,
  });

  Future<void> logout(BuildContext context) async {
    try {
      await AuthService().signOut();

      roleService.completeSessionRestore(null);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80),
            const SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/reports'),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('View Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
