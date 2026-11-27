import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_issue_reporter/models/report_model.dart';

class FakeReportSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? reportData;

  FakeReportSnapshot(this.reportData);

  @override
  String get id => 'RASD-TEST-001';

  @override
  Map<String, dynamic>? data() => reportData;
}

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
    test('Reads legacy reports without new fields', () {
      final report = ReportModel.fromFirestore(
        FakeReportSnapshot(createReportData()),
      );

      expect(report.reportId, 'RASD-TEST-001');
      expect(report.category, 'pothole');
      expect(report.priority, 'medium');
      expect(report.status, 'pending');

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    test('Reads three independent categories', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': 'garbage',
        'citizenSelectedCategory': 'pothole',
        'officialCategory': 'water_leak',
      });

      final report = ReportModel.fromFirestore(FakeReportSnapshot(data));

      expect(report.aiPredictedCategory, 'garbage');
      expect(report.citizenSelectedCategory, 'pothole');
      expect(report.officialCategory, 'water_leak');
    });

    test('Reads employee review status', () {
      final data = createReportData();

      data['reviewStatus'] = 'approved';

      final report = ReportModel.fromFirestore(FakeReportSnapshot(data));

      expect(report.reviewStatus, 'approved');
      expect(report.status, 'pending');
    });

    test('Handles null classification values', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': null,
        'citizenSelectedCategory': null,
        'officialCategory': null,
        'reviewStatus': null,
      });

      final report = ReportModel.fromFirestore(FakeReportSnapshot(data));

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    test('Handles empty and whitespace values', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': '',
        'citizenSelectedCategory': '   ',
        'officialCategory': '',
        'reviewStatus': ' ',
      });

      final report = ReportModel.fromFirestore(FakeReportSnapshot(data));

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    test('Handles invalid classification data types', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': 123,
        'citizenSelectedCategory': true,
        'officialCategory': [],
        'reviewStatus': {},
      });

      final report = ReportModel.fromFirestore(FakeReportSnapshot(data));

      expect(report.aiPredictedCategory, isNull);
      expect(report.citizenSelectedCategory, isNull);
      expect(report.officialCategory, isNull);
      expect(report.reviewStatus, isNull);
    });

    test('Preserves existing Firestore serialization', () {
      final data = createReportData();

      data.addAll({
        'aiPredictedCategory': 'garbage',
        'citizenSelectedCategory': 'pothole',
        'officialCategory': 'pothole',
        'reviewStatus': 'approved',
      });

      final report = ReportModel.fromFirestore(FakeReportSnapshot(data));

      final serialized = report.toFirestore();

      expect(serialized['category'], 'pothole');
      expect(serialized['priority'], 'medium');

      expect(serialized.containsKey('aiPredictedCategory'), isFalse);

      expect(serialized.containsKey('citizenSelectedCategory'), isFalse);

      expect(serialized.containsKey('officialCategory'), isFalse);

      expect(serialized.containsKey('reviewStatus'), isFalse);
    });

    test('Rejects missing report documents', () {
      expect(
        () => ReportModel.fromFirestore(FakeReportSnapshot(null)),
        throwsStateError,
      );
    });
  });
}
