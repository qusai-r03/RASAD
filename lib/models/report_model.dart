import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String citizenId;
  final String? municipalityId;

  // Existing report category.
  final String category;

  // Week 3 classification fields.
  final String? aiPredictedCategory;
  final String? citizenSelectedCategory;
  final String? officialCategory;

  // Employee review status.
  final String? reviewStatus;

  final String description;
  final String status;
  final String priority;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String? imageUrl;

  const ReportModel({
    required this.reportId,
    required this.citizenId,
    this.municipalityId,
    required this.category,
    this.aiPredictedCategory,
    this.citizenSelectedCategory,
    this.officialCategory,
    this.reviewStatus,
    required this.description,
    required this.status,
    required this.priority,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.imageUrl,
  });

  // Preserve the existing Firestore serialization.
  Map<String, dynamic> toFirestore() {
    return {
      'reportId': reportId,
      'citizenId': citizenId,
      'municipalityId': municipalityId,
      'category': category,
      'description': description,
      'status': status,
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
    };
  }

  // Safely read optional string values.
  static String? _readOptionalString(dynamic value) {
    if (value is! String) {
      return null;
    }

    final trimmedValue = value.trim();

    return trimmedValue.isEmpty ? null : trimmedValue;
  }

  // Convert a real Firestore document into ReportModel.
  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError('Report document does not exist.');
    }

    return ReportModel.fromMap(data, document.id);
  }

  // Convert raw report data into ReportModel.
  // This also allows unit testing without mocking DocumentSnapshot.
  factory ReportModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ReportModel(
      reportId: data['reportId'] as String? ?? documentId,

      citizenId: data['citizenId'] as String,

      municipalityId: data['municipalityId'] as String?,

      // Existing report category.
      category: data['category'] as String,

      // Independent classification fields.
      aiPredictedCategory: _readOptionalString(data['aiPredictedCategory']),

      citizenSelectedCategory: _readOptionalString(
        data['citizenSelectedCategory'],
      ),

      officialCategory: _readOptionalString(data['officialCategory']),

      // Employee review decision.
      reviewStatus: _readOptionalString(data['reviewStatus']),

      description: data['description'] as String,

      status: data['status'] as String,

      priority: data['priority'] as String,

      latitude: (data['latitude'] as num).toDouble(),

      longitude: (data['longitude'] as num).toDouble(),

      createdAt: (data['createdAt'] as Timestamp).toDate(),

      imageUrl: data['imageUrl'] as String?,
    );
  }
}
