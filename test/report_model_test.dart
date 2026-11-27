import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_issue_reporter/models/report_model.dart';

Map<String, dynamic> createReportData() {
  return {
    'reportId': 'RASD-TEST-001',
    'citizenId': 'citizenA',
    'municipalityId': 'amman',
    'category': 'pothole',
    'description': 'Test road damage',
    'status': 'pending',
    'priority': 'medium',
    'latitude': 31.9539,
    'longitude': 35.9106,
    'createdAt': Timestamp.fromDate(DateTime(2026, 11, 27)),
    'imageUrl': null,
  };
}

void main() {
  group('ReportModel classification tests', () {
    // Test 1: Backward compatibility with legacy reports.
    test('Reads legacy reports without new fields', () {
      final report = ReportModel.fromMap(createReportData(), 'RASD-TEST-001');

      expect(report.reportId, 'RASD-TEST-001');
      expect(report.category, 'pothole');
      expect(report.priority, 'medium');
      expect(report.status, 'pending');

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    // Test 2: Read three independent category values.
    test('Reads three independent categories', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': 'garbage',
        'citizenSelectedCategory': 'pothole',
        'officialCategory': 'water_leak',
      });

      final report = ReportModel.fromMap(data, 'RASD-TEST-001');

      expect(report.aiPredictedCategory, 'garbage');
      expect(report.citizenSelectedCategory, 'pothole');
      expect(report.officialCategory, 'water_leak');
    });

    // Test 3: Review status is independent of report status.
    test('Reads employee review status', () {
      final data = createReportData();

      data['reviewStatus'] = 'approved';

      final report = ReportModel.fromMap(data, 'RASD-TEST-001');

      expect(report.reviewStatus, 'approved');
      expect(report.status, 'pending');
    });

    // Test 4: Null classification values.
    test('Handles null classification values', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': null,
        'citizenSelectedCategory': null,
        'officialCategory': null,
        'reviewStatus': null,
      });

      final report = ReportModel.fromMap(data, 'RASD-TEST-001');

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    // Test 5: Empty or whitespace-only values.
    test('Handles empty and whitespace values', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': '',
        'citizenSelectedCategory': '   ',
        'officialCategory': '',
        'reviewStatus': ' ',
      });

      final report = ReportModel.fromMap(data, 'RASD-TEST-001');

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    // Test 6: Invalid classification data types.
    test('Handles invalid classification data types', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': 123,
        'citizenSelectedCategory': true,
        'officialCategory': [],
        'reviewStatus': {},
      });

      final report = ReportModel.fromMap(data, 'RASD-TEST-001');

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    // Test 7: Preserve existing Firestore serialization.
    test('Preserves existing Firestore serialization', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': 'garbage',
        'citizenSelectedCategory': 'pothole',
        'officialCategory': 'pothole',
        'reviewStatus': 'approved',
      });

      final report = ReportModel.fromMap(data, 'RASD-TEST-001');

      final serialized = report.toFirestore();

      expect(serialized['category'], 'pothole');
      expect(serialized['priority'], 'medium');
      expect(serialized['status'], 'pending');

      expect(serialized.containsKey('aiPredictedCategory'), isFalse);

      expect(serialized.containsKey('citizenSelectedCategory'), isFalse);

      expect(serialized.containsKey('officialCategory'), isFalse);

      expect(serialized.containsKey('reviewStatus'), isFalse);
    });

    // Test 8: Use the Firestore document ID as a fallback.
    test('Uses document ID when reportId is missing', () {
      final data = createReportData();

      data.remove('reportId');

      final report = ReportModel.fromMap(data, 'FALLBACK-REPORT-ID');

      expect(report.reportId, 'FALLBACK-REPORT-ID');
    });
  });
}
