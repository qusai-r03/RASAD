import '../../models/report_model.dart';
import 'report_service.dart';

class EmployeeHomeData {
  final String municipalityId;
  final List<ReportModel> reports;
  final int pendingCount;
  final int inProgressCount;
  final int resolvedCount;

  const EmployeeHomeData({
    required this.municipalityId,
    required this.reports,
    required this.pendingCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  List<ReportModel> get latestReports => reports.take(3).toList();
}

class EmployeeHomeService {
  final ReportService _reportService;

  EmployeeHomeService({ReportService? reportService})
    : _reportService = reportService ?? ReportService();

  Future<EmployeeHomeData> load(String employeeUid) async {
    // Get the employee's municipality from Firestore.
    final municipalityId = await _reportService.getEmployeeMunicipalityId(
      employeeUid,
    );

    // Fetch reports belonging to that municipality only.
    final reports = await _reportService.getEmployeeReports(municipalityId);

    // Newest reports first.
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int countStatus(String status) {
      return reports
          .where((report) => report.status.trim().toLowerCase() == status)
          .length;
    }

    return EmployeeHomeData(
      municipalityId: municipalityId,
      reports: reports,
      pendingCount: countStatus('pending'),
      inProgressCount: countStatus('in progress'),
      resolvedCount: countStatus('resolved'),
    );
  }
}
