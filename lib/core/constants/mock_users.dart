import '../../models/app_user.dart';
import '../../models/user_role.dart';

class MockUsers {
  static const AppUser citizen = AppUser(
    id: 'mock_citizen_001',
    role: UserRole.citizen,
  );

  static const AppUser employee = AppUser(
    id: 'mock_employee_001',
    role: UserRole.employee,
  );

  static const AppUser admin = AppUser(
    id: 'mock_admin_001',
    role: UserRole.admin,
  );
}
