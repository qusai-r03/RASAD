import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../constants/role_permissions.dart';
import '../services/role_service.dart';
import '../../features/authentication/screens/unauthorized_screen.dart';

class RoleGuard extends StatelessWidget {
  final RoleService roleService;
  final AppPermission requiredPermission;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.roleService,
    required this.requiredPermission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: roleService,
      builder: (context, child) {
        final AppUser? user = roleService.getCurrentUser();

        if (user == null) {
          return const UnauthorizedScreen();
        }

        final bool hasAccess = RolePermissions.hasPermission(
          user.role,
          requiredPermission,
        );

        if (!hasAccess) {
          return const UnauthorizedScreen();
        }

        return this.child;
      },
    );
  }
}
