import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';

class RoleService extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isRestoringSession = true;

  bool get isRestoringSession => _isRestoringSession;

  AppUser? getCurrentUser() {
    return _currentUser;
  }

  UserRole? getCurrentUserRole() {
    return _currentUser?.role;
  }

  void setMockUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearMockUser() {
    _currentUser = null;
    notifyListeners();
  }

  void setAuthenticatedUser({required String uid, required UserRole role}) {
    _currentUser = AppUser(id: uid, role: role);

    notifyListeners();
  }

  void completeSessionRestore(AppUser? user) {
    _currentUser = user;
    _isRestoringSession = false;
    notifyListeners();
  }
}
