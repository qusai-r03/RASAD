import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../models/user_role.dart';

class RoleService extends ChangeNotifier {
  AppUser? _currentUser;

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
}
