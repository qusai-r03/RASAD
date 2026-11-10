import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import 'router.dart';

class RasdApp extends StatefulWidget {
  const RasdApp({super.key});

  @override
  State<RasdApp> createState() => _RasdAppState();
}

class _RasdAppState extends State<RasdApp> {
  bool hasRestoreError = false;

  @override
  void initState() {
    super.initState();
    restoreUserSession();
  }

  Future<void> restoreUserSession() async {
    setState(() {
      hasRestoreError = false;
    });

    try {
      final result = await AuthService().restoreSession();

      if (!mounted) return;

      if (result == null) {
        roleService.completeSessionRestore(null);
        return;
      }

      final UserRole role;

      if (result.role == 'citizen') {
        role = UserRole.citizen;
      } else if (result.role == 'employee') {
        role = UserRole.employee;
      } else {
        throw StateError('Invalid user role');
      }

      roleService.completeSessionRestore(AppUser(id: result.uid, role: role));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        hasRestoreError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );

    if (hasRestoreError) {
      return MaterialApp(
        title: 'RASD',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to verify your session.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: restoreUserSession,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'RASD',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: theme,
    );
  }
}
