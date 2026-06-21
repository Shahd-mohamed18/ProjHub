// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:onboard/utilts/chat_utils.dart';
// import '../../models/message_model.dart';
// import '../../services/notification_service.dart';

// part 'chat_state.dart';

// class ChatCubit extends Cubit<ChatState> {
//   ChatCubit() : super(const ChatState());

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String? _currentChatUserId;

//   void initializeNotifications() {
//     _listenToChatChanges();
//   }
// <<<<<<< Updated upstream

//   void setCurrentChatUser(String? userId) {
//     _currentChatUserId = userId;
//   }

//   void _listenToChatChanges() {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return;

// =======

//   void setCurrentChatUser(String? userId) {
//     _currentChatUserId = userId;
//   }

//   void _listenToChatChanges() {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return;

// >>>>>>> Stashed changes
//     _firestore
//         .collection('chats')
//         .where('users', arrayContains: currentUserId)
//         .snapshots()
//         .listen((snapshot) {
//           for (var doc in snapshot.docChanges) {
// <<<<<<< Updated upstream
//             if (doc.type == DocumentChangeType.modified ||
// =======
//             if (doc.type == DocumentChangeType.modified ||
// >>>>>>> Stashed changes
//                 doc.type == DocumentChangeType.added) {
//               _checkForNewMessage(doc.doc);
//             }
//           }
//         });
//   }
// <<<<<<< Updated upstream

// =======

// >>>>>>> Stashed changes
//   Future<void> _checkForNewMessage(DocumentSnapshot chatDoc) async {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return;

//     final chatData = chatDoc.data() as Map<String, dynamic>?;
//     if (chatData == null) return;

//     final users = List<String>.from(chatData['users']);
//     final otherUserId = users.firstWhere((id) => id != currentUserId);
//     final readBy = List<String>.from(chatData['readBy'] ?? []);
//     final isRead = readBy.contains(currentUserId);
// <<<<<<< Updated upstream

// =======

// >>>>>>> Stashed changes
//     if (isRead || _currentChatUserId == otherUserId) return;

//     final lastMessage = chatData['lastMessage'] ?? '';
//     final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
// <<<<<<< Updated upstream

//     final userData = await getUserData(otherUserId);
//     final senderName = userData?['fullName'] ?? 'Someone';

// =======

//     final userData = await getUserData(otherUserId);
//     final senderName = userData?['fullName'] ?? 'Someone';

// >>>>>>> Stashed changes
//     await NotificationService.showNotification(
//       id:
//           lastMessageTime?.millisecondsSinceEpoch?.remainder(100000) ??
//           DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       title: senderName,
//       body: lastMessage.length > 50
//           ? '${lastMessage.substring(0, 50)}...'
//           : lastMessage,
//       payload: otherUserId,
//     );
//   }

//   Stream<List<ChatUser>> getChatsStream() {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return Stream.value([]);

//     return _firestore
//         .collection('chats')
//         .where('users', arrayContains: currentUserId)
//         .snapshots()
//         .asyncMap((snapshot) async {
//           if (snapshot.docs.isEmpty) return [];

//           List<ChatUser> chatUsers = [];

//           for (var doc in snapshot.docs) {
//             final chatData = doc.data();
//             final users = List<String>.from(chatData['users']);
//             final otherUserId = users.firstWhere((id) => id != currentUserId);
//             final lastMessage = chatData['lastMessage'] ?? '';
//             final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
//             final isRead = chatData['readBy']?.contains(currentUserId) ?? false;

//             try {
//               DocumentSnapshot userDoc = await _firestore
//                   .collection('users')
//                   .doc(otherUserId)
//                   .get();

//               if (userDoc.exists) {
//                 final userData = userDoc.data() as Map<String, dynamic>;
//                 chatUsers.add(
//                   ChatUser(
//                     userId: otherUserId,
//                     name: userData['fullName'] ?? 'Unknown User',
//                     photoUrl: userData['photoUrl'],
//                     university: userData['university'],
//                     lastMessage: lastMessage,
//                     lastMessageTime: lastMessageTime,
//                     isRead: isRead,
//                     chatId: doc.id,
//                   ),
//                 );
//               }
//             } catch (e) {
//               print('Error fetching user data: $e');
//             }
//           }

//           chatUsers.sort((a, b) {
//             if (a.lastMessageTime == null && b.lastMessageTime == null)
//               return 0;
//             if (a.lastMessageTime == null) return 1;
//             if (b.lastMessageTime == null) return -1;
//             return b.lastMessageTime!.compareTo(a.lastMessageTime!);
//           });

//           return chatUsers;
//         });
//   }

//   Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) return Stream.value([]);

//     final chatId = getChatId(currentUserId, otherUserId);

//     return _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             final data = doc.data();
//             return MessageModel.fromJson(data);
//           }).toList();
//         });
//   }

//   Future<Map<String, dynamic>?> getUserData(String userId) async {
//     try {
//       DocumentSnapshot doc = await _firestore
//           .collection('users')
//           .doc(userId)
//           .get();

//       if (doc.exists) {
//         return doc.data() as Map<String, dynamic>;
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//     return null;
//   }

// <<<<<<< Updated upstream
//   // ✅ دالة جديدة للبحث عن userId باستخدام الاسم
//   Future<String?> findUserIdByName(String name) async {
//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .where('fullName', isEqualTo: name)
//           .limit(1)
//           .get();
//       if (snapshot.docs.isNotEmpty) {
//         return snapshot.docs.first.id;
//       }
//       print('⚠️ No user found with name: $name');
//       return null;
//     } catch (e) {
//       print('❌ Error finding user by name: $e');
//       return null;
//     }
//   }

// =======
// >>>>>>> Stashed changes
//   Future<void> sendMessage(String otherUserId, String message) async {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null || message.trim().isEmpty) return;

//     final chatId = getChatId(currentUserId, otherUserId);
//     final currentUserData = await getUserData(currentUserId);
//     final receiverData = await getUserData(otherUserId);

//     try {
//       await _firestore.collection('chats').doc(chatId).set({
//         'users': [currentUserId, otherUserId],
//         'lastMessage': message,
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         'readBy': [currentUserId],
//       }, SetOptions(merge: true));

//       await _firestore
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .add({
//             'message': message,
//             'senderId': currentUserId,
//             'createdAt': FieldValue.serverTimestamp(),
//           });

//       emit(state.copyWith(successMessage: 'Message sent'));
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: ChatStatus.error,
//           errorMessage: 'Error sending message: $e',
//         ),
//       );
//   }
//   Future<void> markMessagesAsRead(String otherUserId) async {
//     if (currentUserId == null) return;

//     final chatId = getChatId(currentUserId, otherUserId);

//     try {
//       await _firestore.collection('chats').doc(chatId).update({
//         'readBy': FieldValue.arrayUnion([currentUserId]),
//       });
//       // Silent fail
//     }
//   }

//   void clearMessages() {
//     emit(state.copyWith(errorMessage: null, successMessage: null));
//   }

//   @override
//     _currentChatUserId = null;
//     return super.close();
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/utilts/chat_utils.dart';
import '../../models/message_model.dart';
import '../../services/notification_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentChatUserId;

  void initializeNotifications() {
    _listenToChatChanges();
  }

  void setCurrentChatUser(String? userId) {
    _currentChatUserId = userId;
  }

  void _listenToChatChanges() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docChanges) {
            if (doc.type == DocumentChangeType.modified ||
                doc.type == DocumentChangeType.added) {
              _checkForNewMessage(doc.doc);
            }
          }
        });
  }

  Future<void> _checkForNewMessage(DocumentSnapshot chatDoc) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final chatData = chatDoc.data() as Map<String, dynamic>?;
    if (chatData == null) return;

    final users = List<String>.from(chatData['users']);
    final otherUserId = users.firstWhere((id) => id != currentUserId);

    final readBy = List<String>.from(chatData['readBy'] ?? []);
    final isRead = readBy.contains(currentUserId);

    if (isRead || _currentChatUserId == otherUserId) return;

    final lastMessage = chatData['lastMessage'] ?? '';
    final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;

    final userData = await getUserData(otherUserId);
    final senderName = userData?['fullName'] ?? 'Someone';

    await NotificationService.showNotification(
      id:
          lastMessageTime?.millisecondsSinceEpoch.remainder(100000) ??
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: senderName,
      body: lastMessage.length > 50
          ? '${lastMessage.substring(0, 50)}...'
          : lastMessage,
      payload: otherUserId,
    );
  }

  Stream<List<ChatUser>> getChatsStream() {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];

          List<ChatUser> chatUsers = [];

          for (var doc in snapshot.docs) {
            final chatData = doc.data();

            final users = List<String>.from(chatData['users']);

            final otherUserId = users.firstWhere((id) => id != currentUserId);

            final lastMessage = chatData['lastMessage'] ?? '';

            final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;

            final isRead = chatData['readBy']?.contains(currentUserId) ?? false;

            try {
              DocumentSnapshot userDoc = await _firestore
                  .collection('users')
                  .doc(otherUserId)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;

                chatUsers.add(
                  ChatUser(
                    userId: otherUserId,
                    name: userData['fullName'] ?? 'Unknown User',
                    photoUrl: userData['photoUrl'],
                    university: userData['university'],
                    lastMessage: lastMessage,
                    lastMessageTime: lastMessageTime,
                    isRead: isRead,
                    chatId: doc.id,
                  ),
                );
              }
            } catch (e) {
              print('Error fetching user data: $e');
            }
          }

          chatUsers.sort((a, b) {
            if (a.lastMessageTime == null && b.lastMessageTime == null)
              return 0;

            if (a.lastMessageTime == null) return 1;

            if (b.lastMessageTime == null) return -1;

            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          return chatUsers;
        });
  }

  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Stream.value([]);
    }

    final chatId = getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromJson(doc.data());
          }).toList();
        });
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    return null;
  }

  Future<String?> findUserIdByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('fullName', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }

      return null;
    } catch (e) {
      print('Error finding user: $e');

      return null;
    }
  }

  Future<void> sendMessage(String otherUserId, String message) async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null || message.trim().isEmpty) return;

    final chatId = getChatId(currentUserId, otherUserId);

    try {
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUserId, otherUserId],

        'lastMessage': message,

        'lastMessageTime': FieldValue.serverTimestamp(),

        'readBy': [currentUserId],
      }, SetOptions(merge: true));

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'message': message,

            'senderId': currentUserId,

            'createdAt': FieldValue.serverTimestamp(),
          });

      emit(state.copyWith(successMessage: 'Message sent'));
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Error sending message: $e',
        ),
      );
    }
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) return;

    final chatId = getChatId(currentUserId, otherUserId);

    try {
      await _firestore.collection('chats').doc(chatId).update({
        'readBy': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      print(e);
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  @override
  Future<void> close() {
    _currentChatUserId = null;

    return super.close();
  }
}
