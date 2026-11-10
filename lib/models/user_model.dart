import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String city;
  final String phoneNumber;
  final bool phoneVerified;
  final String identityVerificationStatus;
  final String role;
  final String status;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.city,
    required this.phoneNumber,
    required this.phoneVerified,
    required this.identityVerificationStatus,
    required this.role,
    required this.status,
    this.createdAt,
  });

  // Convert Firestore data into a UserModel
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw StateError('User document does not exist.');
    }

    return UserModel(
      uid: document.id,
      username: data['username'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      dateOfBirth: data['dateOfBirth'] as String,
      city: data['city'] as String,
      phoneNumber: data['phoneNumber'] as String,
      phoneVerified: data['phoneVerified'] as bool,
      identityVerificationStatus: data['identityVerificationStatus'] as String,
      role: data['role'] as String,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert UserModel into Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'city': city,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
      'identityVerificationStatus': identityVerificationStatus,
      'role': role,
      'status': status,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
