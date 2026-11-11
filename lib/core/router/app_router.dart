import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/current_user_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/complaints/complaint_detail_screen.dart';
import '../../features/complaints/new_complaint_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/places/saved_places_screen.dart';
import '../../features/profile/change_password_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/help_screen.dart';
import '../../features/route/route_check_screen.dart';
import '../../features/complaints/reports_screen.dart';
import '../../features/complaints/update_status_screen.dart';
import '../../features/complaints/update_success_screen.dart';
import '../../features/home/citizen_home_screen.dart';
import '../../features/home/employee_home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../models/models.dart';

/// خريطة المسارات
///   /login                       تسجيل الدخول (Auth)
///   /home /reports /map /profile  التبويبات (داخل الـ Shell)
///   /complaint/:id               تفاصيل شكوى
///   /complaint-update/:id        تحديث الحالة (موظف)
///   /complaint-updated/:id       شاشة النجاح
///   /new-complaint /notifications /saved-places /route-check /edit-profile /change-password /help
/// مسارات الشكوى خارج الـ Shell عمداً (بدون شريط تنقل) وتُفتح بـ context.push.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<AppUser?>(ref.read(currentUserProvider));
  ref.listen<AppUser?>(currentUserProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final atLogin = state.matchedLocation == '/login';
      if (user == null) return atLogin ? null : '/login';
      if (atLogin) return '/home';
      return null;
    },
    routes: [
      // TODO(Auth): عضو الـ Auth يستبدل هذه الشاشة بشاشة تسجيل الدخول الحقيقية
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/new-complaint', builder: (_, __) => const NewComplaintScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/saved-places', builder: (_, __) => const SavedPlacesScreen()),
      GoRoute(path: '/route-check', builder: (_, __) => const RouteCheckScreen()),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(
        path: '/complaint/:id',
        builder: (_, state) => ComplaintDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/complaint-update/:id',
        builder: (_, state) => UpdateStatusScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/complaint-updated/:id',
        builder: (_, state) => UpdateSuccessScreen(id: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, _) => Consumer(builder: (_, ref, __) {
                final role = ref.watch(currentUserProvider)?.role;
                return role == UserRole.employee ? const EmployeeHomeScreen() : const CitizenHomeScreen();
              }),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reports',
              builder: (_, state) => ReportsScreen(statusFilter: state.uri.queryParameters['status']),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
