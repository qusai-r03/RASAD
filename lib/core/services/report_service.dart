import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore;

  ReportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Proposed official categories.
  static const Set<String> allowedCategories = {
    'pothole',
    'garbage',
    'street_light',
    'water_leak',
  };

  // Allowed employee review decisions.
  static const Set<String> allowedReviewDecisions = {'approved', 'rejected'};

  static const Set<String> allowedPriorities = {'low', 'medium', 'high'};

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

  // Get reports belonging to a citizen.
  Future<List<ReportModel>> getCitizenReports(String citizenId) async {
    final snapshot = await _reportsCollection
        .where('citizenId', isEqualTo: citizenId)
        .get();

    return snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();
  }

  // Get reports belonging to an employee's municipality.
  Future<List<ReportModel>> getEmployeeReports(String municipalityId) async {
    final snapshot = await _reportsCollection
        .where('municipalityId', isEqualTo: municipalityId)
        .get();

    return snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();
  }

  // Get the municipality assigned to an employee.
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

  // Update report priority.
  Future<void> updateReportPriority({
    required String reportId,
    required String priority,
  }) async {
    if (!allowedPriorities.contains(priority)) {
      throw ArgumentError('Invalid report priority.');
    }

    await _reportsCollection.doc(reportId).update({'priority': priority});
  }

  // Update the official report category.
  Future<void> updateOfficialCategory({
    required String reportId,
    required String officialCategory,
  }) async {
    if (reportId.trim().isEmpty) {
      throw ArgumentError('Report ID cannot be empty.');
    }

    if (!allowedCategories.contains(officialCategory)) {
      throw ArgumentError('Invalid official category.');
    }

    await _reportsCollection.doc(reportId).update({
      'officialCategory': officialCategory,
    });
  }

  // Update the employee's review decision.
  Future<void> updateReviewStatus({
    required String reportId,
    required String reviewStatus,
  }) async {
    if (reportId.trim().isEmpty) {
      throw ArgumentError('Report ID cannot be empty.');
    }

    if (!allowedReviewDecisions.contains(reviewStatus)) {
      throw ArgumentError('Invalid review decision.');
    }

    await _reportsCollection.doc(reportId).update({
      'reviewStatus': reviewStatus,
    });
  }
}
