import '../../models/report_model.dart';
import 'report_service.dart';

class CitizenHomeData {
  final List<ReportModel> reports;
  final int pendingCount;
  final int inProgressCount;
  final int resolvedCount;

  const CitizenHomeData({
    required this.reports,
    required this.pendingCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  ReportModel? get latestReport => reports.isEmpty ? null : reports.first;
}

class CitizenHomeService {
  final ReportService _reportService;

  CitizenHomeService({ReportService? reportService})
    : _reportService = reportService ?? ReportService();

  Future<CitizenHomeData> load(String citizenUid) async {
    final reports = await _reportService.getCitizenReports(citizenUid);

    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return CitizenHomeData(
      reports: reports,
      pendingCount: reports
          .where((report) => report.status.trim().toLowerCase() == 'pending')
          .length,
      inProgressCount: reports
          .where(
            (report) => report.status.trim().toLowerCase() == 'in progress',
          )
          .length,
      resolvedCount: reports
          .where((report) => report.status.trim().toLowerCase() == 'resolved')
          .length,
    );
  }
}
