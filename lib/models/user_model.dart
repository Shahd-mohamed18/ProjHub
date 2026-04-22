

// import 'package:cloud_firestore/cloud_firestore.dart';

// enum UserRole {
//   user,        // كان student
//   assistant,
//   supervisor,  // كان doctor
// }

// extension UserRoleExtension on UserRole {
//   String get value {
//     switch (this) {
//       case UserRole.user:
//         return 'user';
//       case UserRole.assistant:
//         return 'assistant';
//       case UserRole.supervisor:
//         return 'supervisor';
//     }
//   }

//   static UserRole fromString(String role) {
//     switch (role) {
//       case 'user':
//         return UserRole.user;
//       case 'assistant':
//         return UserRole.assistant;
//       case 'supervisor':
//         return UserRole.supervisor;
//       default:
//         return UserRole.user;
//     }
//   }
// }

// class UserModel {
//   final String uid;
//   final String email;
//   final String fullName;
//   final UserRole role;
//   final String? photoUrl;
//   final String? bio;
  
//   // User specific fields (كانت student)
//   final String? university;
//   final String? faculty;
//   final String? track;
  
//   // Supervisor/Assistant specific fields (كانت doctor/assistant)
//   final String? position;
//   final String? department;

//   UserModel({
//     required this.uid,
//     required this.email,
//     required this.fullName,
//     required this.role,
//     this.photoUrl,
//     this.bio,
//     this.university,
//     this.faculty,
//     this.track,
//     this.position,
//     this.department,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'fullName': fullName,
//       'role': role.value,
//       'photoUrl': photoUrl,
//       'bio': bio ?? 'No bio yet',
//       'university': university,
//       'faculty': faculty,
//       'track': track,
//       'position': position,
//       'department': department,
//       'createdAt': FieldValue.serverTimestamp(),
//     };
//   }

//   factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
//     return UserModel(
//       uid: uid,
//       email: map['email'] ?? '',
//       fullName: map['fullName'] ?? '',
//       role: UserRoleExtension.fromString(map['role'] ?? 'user'),
//       photoUrl: map['photoUrl'],
//       bio: map['bio'] ?? 'No bio yet',
//       university: map['university'],
//       faculty: map['faculty'],
//       track: map['track'],
//       position: map['position'],
//       department: map['department'],
//     );
//   }
// }



// import 'package:cloud_firestore/cloud_firestore.dart';

// enum UserRole {
//   user,
//   assistant,
//   supervisor,
// }

// extension UserRoleExtension on UserRole {
//   String get value {
//     switch (this) {
//       case UserRole.user:
//         return 'user';
//       case UserRole.assistant:
//         return 'assistant';
//       case UserRole.supervisor:
//         return 'supervisor';
//     }
//   }

//   static UserRole fromString(String role) {
//     switch (role) {
//       case 'user':
//         return UserRole.user;
//       case 'assistant':
//         return UserRole.assistant;
//       case 'supervisor':
//         return UserRole.supervisor;
//       default:
//         return UserRole.user;
//     }
//   }
// }

// class UserModel {
//   final String uid;
//   final String email;
//   final String fullName;
//   final UserRole role;
//   final String? photoUrl;
//   final String? bio;
  
//   // User specific fields
//   final String? university;
//   final String? faculty;
//   final String? track;
  
//   // Supervisor/Assistant specific fields
//   final String? position;
//   final String? department;

//   UserModel({
//     required this.uid,
//     required this.email,
//     required this.fullName,
//     required this.role,
//     this.photoUrl,
//     this.bio,
//     this.university,
//     this.faculty,
//     this.track,
//     this.position,
//     this.department,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'fullName': fullName,
//       'role': role.value,
//       'photoUrl': photoUrl,
//       'bio': bio ?? 'No bio yet',
//       'university': university,
//       'faculty': faculty,
//       'track': track,
//       'position': position,
//       'department': department,
//       'createdAt': FieldValue.serverTimestamp(),
//     };
//   }

//   factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
//     return UserModel(
//       uid: uid,
//       email: map['email'] ?? '',
//       fullName: map['fullName'] ?? '',
//       role: UserRoleExtension.fromString(map['role'] ?? 'user'),
//       photoUrl: map['photoUrl'],
//       bio: map['bio'] ?? 'No bio yet',
//       university: map['university'],
//       faculty: map['faculty'],
//       track: map['track'],
//       position: map['position'],
//       department: map['department'],
//     );
//   }

//   // 🔴 جديد: تحويل البيانات عشان تبعت للـ API
//   Map<String, dynamic> toApiJson() {
//     return {
//       'uid': uid,
//       'fullName': fullName,
//       'email': email,
//       'university': university,
//       'faculty': faculty,
//       'track': track,
//       'role': role.value,
//       'picture': photoUrl ?? '',
//     };
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  assistant,
  supervisor,
}

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
  
  // User specific fields
  final String? university;
  final String? faculty;
  final String? track;
  
  // Supervisor/Assistant specific fields
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

  // تحويل البيانات للـ API مع حل مشكلة الصورة و Error 400
  Map<String, dynamic> toApiJson() {
    final Map<String, dynamic> json = {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role.value,
      'picture': '',  // دايمًا empty string عشان نتجنب مشكلة المسار المحلي
    };

    // إضافة الحقول حسب الدور لتجنب Error 400
    if (role == UserRole.user) {
      // للمستخدم العادي
      json['university'] = university ?? 'Not specified';
      json['faculty'] = faculty ?? 'Not specified';
      json['track'] = track ?? 'General';
    } else {
      // للمشرفين والمساعدين
      json['university'] = department ?? university ?? 'University';
      json['faculty'] = position ?? faculty ?? 'Faculty';
      json['track'] = track ?? 'Management';
    }

    return json;
  }
}