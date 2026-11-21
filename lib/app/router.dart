import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/complaints/screens/add_report_screen.dart';
import '../features/complaints/screens/report_details_screen.dart';
import '../features/complaints/screens/reports_screen.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/profile/profile_screen.dart';

import '../shared/widgets/employee_shell.dart';
import '../shared/widgets/citizen_shell.dart';

import '../models/user_role.dart';

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

    // Protect authenticated application pages.
    if ((path == '/dashboard' ||
            path == '/reports' ||
            path.startsWith('/reports/') ||
            path == '/profile' ||
            path == '/add-report') &&
        role == null) {
      return '/login';
    }

    // Only citizens can create reports.
    if (path == '/add-report' && role != UserRole.citizen) {
      return '/dashboard';
    }

    // Protect employee-only routes.
    if (path.startsWith('/employee/') && role == null) {
      return '/login';
    }

    return null;
  },

  routes: [
    // Loading Screen.
    GoRoute(
      path: '/loading',
      builder: (context, state) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    ),

    // Welcome Screen.
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Scaffold(
          body: Center(
            child: Text('Welcome to RASD'),
          ),
        );
      },
    ),

    // Login Screen.
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Shared Navigation Shell.
    ShellRoute(
      builder: (context, state, child) {
        final role = roleService.getCurrentUserRole();

        if (role == UserRole.citizen) {
          return CitizenShell(child: child);
        }

        if (role == UserRole.employee) {
          return EmployeeShell(child: child);
        }

        return child;
      },

      routes: [
        // Add Report Screen - Citizens Only.
        GoRoute(
          path: '/add-report',
          builder: (context, state) {
            return const AddReportScreen();
          },
        ),

        // Citizen or Employee Dashboard.
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Not authenticated'),
                ),
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

        // Reports Screen.
        GoRoute(
          path: '/reports',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Not authenticated'),
                ),
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

        // Report Details Screen - Member 3 Integration.
        GoRoute(
          path: '/reports/:reportId',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Not authenticated'),
                ),
              );
            }

            final permission = role == UserRole.citizen
                ? AppPermission.viewOwnReports
                : AppPermission.viewMunicipalityReports;

            final reportId = state.pathParameters['reportId']!;

            return RoleGuard(
              roleService: roleService,
              requiredPermission: permission,
              child: ReportDetailsScreen(
                reportId: reportId,
              ),
            );
          },
        ),

        // Profile Screen.
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            final role = roleService.getCurrentUserRole();

            if (role == null) {
              return const Scaffold(
                body: Center(
                  child: Text('Not authenticated'),
                ),
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

    // Employee Reports.
    GoRoute(
      path: '/employee/reports',
      builder: (context, state) {
        return RoleGuard(
          roleService: roleService,
          requiredPermission: AppPermission.viewMunicipalityReports,
          child: const Scaffold(
            body: Center(
              child: Text('Employee Reports - Access Granted'),
            ),
          ),
        );
      },
    ),
  ],
);