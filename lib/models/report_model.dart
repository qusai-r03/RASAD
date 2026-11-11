import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String reportId;
  final String citizenId;
  final String? municipalityId;
  final String category;
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
    required this.description,
    required this.status,
    required this.priority,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.imageUrl,
  });

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

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError('Report document does not exist.');
    }

    return ReportModel(
      reportId: data['reportId'] as String? ?? document.id,
      citizenId: data['citizenId'] as String,
      municipalityId: data['municipalityId'] as String?,
      category: data['category'] as String,
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
