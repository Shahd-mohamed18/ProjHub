// import 'package:cloud_firestore/cloud_firestore.dart';

// class MessageModel {
//   final String message;
//   final String senderId;
//   final Timestamp createdAt;

//   MessageModel({
//     required this.message,
//     required this.senderId,
//     required this.createdAt,
//   });

//   factory MessageModel.fromJson(Map<String, dynamic> json) {
//     return MessageModel(
//       message: json['message'] ?? '',
//       senderId: json['senderId'] ?? '',
//       createdAt: json['createdAt'] ?? Timestamp.now(),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String message;
  final String senderId;
  final Timestamp createdAt;

  MessageModel({
    required this.message,
    required this.senderId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      message: json['message'] ?? '',
      senderId: json['senderId'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }
}