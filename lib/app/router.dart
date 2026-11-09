import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/screens/login_screen.dart';
import '../core/constants/role_permissions.dart';
import '../core/routing/role_guard.dart';
import '../core/routing/role_dashboard.dart';
import '../core/services/role_service.dart';

final RoleService roleService = RoleService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  refreshListenable: roleService,

  redirect: (context, state) {
    final role = roleService.getCurrentUserRole();
    final path = state.uri.path;

    // Open login if the user is not authenticated.
    if (path == '/') {
      return role == null ? '/login' : '/dashboard';
    }

    // Already signed-in users go to their dashboard.
    if (path == '/login' && role != null) {
      return '/dashboard';
    }

    // Protect the dashboard.
    if (path == '/dashboard' && role == null) {
      return '/login';
    }

    // Protect employee-only routes.
    if (path.startsWith('/employee/') && role == null) {
      return '/login';
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

    // Ghazal's original login screen.
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Citizen or employee dashboard based on role.
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final role = roleService.getCurrentUserRole();

        if (role == null) {
          return const Scaffold(body: Center(child: Text('Not authenticated')));
        }

        return RoleDashboard(role: role);
      },
    ),

    // Employee reports.
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
