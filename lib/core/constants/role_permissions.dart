import '../../models/user_role.dart';

enum AppPermission {
  viewCitizenHome,
  viewEmployeeHome,
  createReport,
  viewOwnReports,
  viewMunicipalityReports,
  updateReportStatus,
  correctReportCategory,
  adjustReportPriority,
}

class RolePermissions {
  static const Map<UserRole, Set<AppPermission>> permissions = {
    UserRole.citizen: {
      AppPermission.viewCitizenHome,
      AppPermission.createReport,
      AppPermission.viewOwnReports,
    },

    UserRole.employee: {
      AppPermission.viewEmployeeHome,
      AppPermission.viewMunicipalityReports,
      AppPermission.updateReportStatus,
      AppPermission.correctReportCategory,
      AppPermission.adjustReportPriority,
    },
  };

  // Returns false if the role has no permissions or the permission is not granted.
  static bool hasPermission(UserRole role, AppPermission permission) {
    return permissions[role]?.contains(permission) ?? false;
  }
}
