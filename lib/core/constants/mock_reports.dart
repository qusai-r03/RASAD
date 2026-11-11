import '../../models/report_model.dart';

class MockReports {
  static final List<ReportModel> reportModels = [
    ReportModel(
      reportId: 'CMP-001',
      citizenId: 'demo_citizen_001',
      category: 'Pothole',
      description: 'A pothole on the main road.',
      status: 'Pending',
      priority: 'High',
      latitude: 32.5556,
      longitude: 35.8500,
      createdAt: DateTime(2026, 11, 9),
    ),
    ReportModel(
      reportId: 'CMP-002',
      citizenId: 'demo_citizen_001',
      category: 'Garbage Accumulation',
      description: 'Garbage has accumulated near the street.',
      status: 'In Progress',
      priority: 'Medium',
      latitude: 32.5560,
      longitude: 35.8510,
      createdAt: DateTime(2026, 11, 8),
    ),
    ReportModel(
      reportId: 'CMP-003',
      citizenId: 'demo_citizen_001',
      category: 'Damaged Sidewalk',
      description: 'The sidewalk requires maintenance.',
      status: 'Resolved',
      priority: 'Low',
      latitude: 32.5570,
      longitude: 35.8520,
      createdAt: DateTime(2026, 11, 7),
    ),
  ];
}
