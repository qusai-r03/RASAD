import 'package:flutter/material.dart';

import '../../models/user_role.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
          ],
        ),
      ),
    );
  }
}
