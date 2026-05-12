import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, assistant, supervisor }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.assistant:
        return 'assistant';
      case UserRole.supervisor:
        return 'supervisor';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'user':
        return UserRole.user;
      case 'assistant':
        return UserRole.assistant;
      case 'supervisor':
        return UserRole.supervisor;
      default:
        return UserRole.user;
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final String? bio;
  final String? university;
  final String? faculty;
  final String? track;
  final String? position;
  final String? department;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.bio,
    this.university,
    this.faculty,
    this.track,
    this.position,
    this.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role.value,
      'photoUrl': photoUrl,
      'bio': bio ?? 'No bio yet',
      'university': university,
      'faculty': faculty,
      'track': track,
      'position': position,
      'department': department,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: UserRoleExtension.fromString(map['role'] ?? 'user'),
      photoUrl: map['photoUrl'],
      bio: map['bio'] ?? 'No bio yet',
      university: map['university'],
      faculty: map['faculty'],
      track: map['track'],
      position: map['position'],
      department: map['department'],
    );
  }

  Map<String, dynamic> toApiJsonWithoutImage() {
    return {
      'Id': uid,
      'FullName': fullName,
      'Email': email,
      'Role': role.value,
      'Instituation': university ?? department ?? 'Not specified',
      'Faculty': faculty ?? position ?? 'Not specified',
      'Track': track ?? 'General',
    };
  }
}
