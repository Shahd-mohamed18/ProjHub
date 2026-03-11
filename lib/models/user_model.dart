// // lib/models/user_model.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:onboard/models/user_model.dart';

// class UserModel {
//   final String uid;
//   final String email;
//   final String fullName;
//   final String university;
//   final String faculty;
//   final String track;
//   final String? photoUrl;
//   final String? bio;
  

//   UserModel({
//     required this.uid,
//     required this.email,
//     required this.fullName,
//     required this.university,
//     required this.faculty,
//     required this.track,
//     this.photoUrl,
//     this.bio,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'fullName': fullName,
//       'university': university,
//       'faculty': faculty,
//       'track': track,
//       'photoUrl': photoUrl,
//       'bio': bio ?? 'No bio yet',
//     };
//   }

//   factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
//     return UserModel(
//       uid: uid,
//       email: map['email'] ?? '',
//       fullName: map['fullName'] ?? '',
//       university: map['university'] ?? '',
//       faculty: map['faculty'] ?? '',
//       track: map['track'] ?? '',
//       photoUrl: map['photoUrl'],
//       bio: map['bio'] ?? 'No bio yet',
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  assistant,
  doctor,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.assistant:
        return 'assistant';
      case UserRole.doctor:
        return 'doctor';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'student':
        return UserRole.student;
      case 'assistant':
        return UserRole.assistant;
      case 'doctor':
        return UserRole.doctor;
      default:
        return UserRole.student;
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
  
  // Student specific fields
  final String? university;
  final String? faculty;
  final String? track;
  
  // Doctor/Assistant specific fields
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
      role: UserRoleExtension.fromString(map['role'] ?? 'student'),
      photoUrl: map['photoUrl'],
      bio: map['bio'] ?? 'No bio yet',
      university: map['university'],
      faculty: map['faculty'],
      track: map['track'],
      position: map['position'],
      department: map['department'],
    );
  }
}