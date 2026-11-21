import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  // Get a report by its ID.
  Future<ReportModel?> getReportById(String reportId) async {
    final document = await _reportsCollection.doc(reportId).get();

    if (!document.exists) {
      return null;
    }

    return ReportModel.fromFirestore(document);
  }

  // Get all reports belonging to a specific citizen.
  Future<List<ReportModel>> getCitizenReports(String citizenId) async {
    final snapshot = await _reportsCollection
        .where('citizenId', isEqualTo: citizenId)
        .get();

    return snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();
  }

  // Get reports belonging to a specific municipality.
  Future<List<ReportModel>> getEmployeeReports(String municipalityId) async {
    final snapshot = await _reportsCollection
        .where('municipalityId', isEqualTo: municipalityId)
        .get();

    return snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();
  }

  // Get the municipality ID assigned to an employee.
  Future<String> getEmployeeMunicipalityId(String employeeUid) async {
    final document = await _firestore
        .collection('employees')
        .doc(employeeUid)
        .get();

    if (!document.exists) {
      throw StateError('Employee profile not found.');
    }

    final municipalityId = document.data()?['municipalityId'];

    if (municipalityId is! String || municipalityId.trim().isEmpty) {
      throw StateError('Employee municipality is missing.');
    }

    return municipalityId;
  }

  // Update the priority of a report.
  // Firestore Security Rules must enforce employee authorization.
  Future<void> updateReportPriority({
    required String reportId,
    required String priority,
  }) async {
    const allowedPriorities = {'low', 'medium', 'high'};

    if (!allowedPriorities.contains(priority)) {
      throw ArgumentError('Invalid report priority.');
    }

    await _reportsCollection.doc(reportId).update({
      'priority': priority,
    });
  }
}