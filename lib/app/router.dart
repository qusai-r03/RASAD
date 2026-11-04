import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/role_permissions.dart';
import '../core/routing/role_guard.dart';
import '../core/routing/mock_role_screen.dart';
import '../core/routing/role_dashboard.dart';
import '../core/services/role_service.dart';

final RoleService roleService = RoleService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  refreshListenable: roleService,

  redirect: (context, state) {
    final role = roleService.getCurrentUserRole();
    final path = state.uri.path;

    // Redirect from the initial page.
    if (path == '/') {
      return role == null ? '/mock-role' : '/dashboard';
    }

    // Redirect selected users to their dashboard.
    if (path == '/mock-role' && role != null) {
      return '/dashboard';
    }

    // Prevent access to the dashboard without a user.
    if (path == '/dashboard' && role == null) {
      return '/mock-role';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Scaffold(body: Center(child: Text('Welcome to RASD')));
      },
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const Scaffold(body: Center(child: Text('Login Screen')));
      },
    ),

    GoRoute(
      path: '/mock-role',
      builder: (context, state) {
        return MockRoleScreen(roleService: roleService);
      },
    ),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final role = roleService.getCurrentUserRole();

        if (role == null) {
          return const Scaffold(body: Center(child: Text('No user selected')));
        }

        return RoleDashboard(role: role);
      },
    ),
    GoRoute(
      path: '/employee/reports',
      builder: (context, state) {
        return RoleGuard(
          roleService: roleService,
          requiredPermission: AppPermission.viewMunicipalityReports,
          child: const Scaffold(
            body: Center(child: Text('Employee Reports - Access Granted')),
          ),
        );
      },
    ),
  ],
);
