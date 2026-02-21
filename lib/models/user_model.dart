// lib/models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/models/user_model.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String university;
  final String faculty;
  final String track;
  final String? photoUrl;
  final String? bio;
  

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.university,
    required this.faculty,
    required this.track,
    this.photoUrl,
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'university': university,
      'faculty': faculty,
      'track': track,
      'photoUrl': photoUrl,
      'bio': bio ?? 'No bio yet',
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      university: map['university'] ?? '',
      faculty: map['faculty'] ?? '',
      track: map['track'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'] ?? 'No bio yet',
    );
  }
}