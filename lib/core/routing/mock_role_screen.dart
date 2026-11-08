import 'package:flutter/material.dart';

import '../../core/constants/mock_users.dart';
import '../../core/services/role_service.dart';
import '../../models/app_user.dart';

class MockRoleScreen extends StatelessWidget {
  final RoleService roleService;

  const MockRoleScreen({super.key, required this.roleService});

  void selectUser(AppUser user) {
    roleService.setMockUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RASD – Development Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select a test account', style: TextStyle(fontSize: 20)),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                selectUser(MockUsers.citizen);
              },
              child: const Text('Citizen'),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                selectUser(MockUsers.employee);
              },
              child: const Text('Employee'),
            ),
            const SizedBox(height: 30),

            ListenableBuilder(
              listenable: roleService,
              builder: (context, child) {
                final user = roleService.getCurrentUser();

                if (user == null) {
                  return const Text('No test user selected');
                }

                return Column(
                  children: [
                    Text('Current User: ${user.id}'),
                    Text('Current Role: ${user.role.name}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
