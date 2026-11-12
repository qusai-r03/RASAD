import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/profile/profile_screen.dart';
import '../features/complaints/screens/reports_screen.dart';
import '../shared/widgets/citizen_shell.dart';
import '../models/user_role.dart';
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
    // Wait until Firebase session restoration finishes.
    if (roleService.isRestoringSession) {
      return path == '/loading' ? null : '/loading';
    }

    // Leave loading screen after session restoration.
    if (path == '/loading') {
      return role == null ? '/login' : '/dashboard';
    }

    // Open login if the user is not authenticated.
    if (path == '/') {
      return role == null ? '/login' : '/dashboard';
    }

    // Already signed-in users go to their dashboard.
    if (path == '/login' && role != null) {
      return '/dashboard';
    }

    // Protect the dashboard.
    // Protect authenticated application pages.
    if ((path == '/dashboard' || path == '/reports' || path == '/profile') &&
        role == null) {
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
      path: '/loading',
      builder: (context, state) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Scaffold(body: Center(child: Text('Welcome to RASD')));
      },
    ),

    // Ghazal's original login screen.
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) {
        final role = roleService.getCurrentUserRole();

        // Citizen pages share one persistent bottom navigation bar.
        if (role == UserRole.citizen) {
          return CitizenShell(child: child);
        }

        // Employee pages keep their own layout.
        return child;
      },
      routes: [
        // Citizen or employee dashboard based on role.
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(child: Text('Not authenticated')),
              );
            }

            final permission = role == UserRole.citizen
                ? AppPermission.viewCitizenHome
                : AppPermission.viewEmployeeHome;

            return RoleGuard(
              roleService: roleService,
              requiredPermission: permission,
              child: RoleDashboard(role: role),
            );
          },
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(child: Text('Not authenticated')),
              );
            }

            final permission = role == UserRole.citizen
                ? AppPermission.viewOwnReports
                : AppPermission.viewMunicipalityReports;

            return RoleGuard(
              roleService: roleService,
              requiredPermission: permission,
              child: const ReportsScreen(),
            );
          },
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(child: Text('Not authenticated')),
              );
            }

            final permission = role == UserRole.citizen
                ? AppPermission.viewCitizenHome
                : AppPermission.viewEmployeeHome;

            return RoleGuard(
              roleService: roleService,
              requiredPermission: permission,
              child: const ProfileScreen(),
            );
          },
        ),
      ],
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
