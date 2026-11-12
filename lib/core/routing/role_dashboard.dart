import 'package:flutter/material.dart';

import '../../models/user_role.dart';
import '../../features/home/citizen_home_screen.dart';
import '../../features/home/employee_home_screen.dart';

class RoleDashboard extends StatelessWidget {
  final UserRole role;

  const RoleDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.citizen:
        return const CitizenHomeScreen();

      case UserRole.employee:
        return const EmployeeHomeScreen();
    }
  }
}
