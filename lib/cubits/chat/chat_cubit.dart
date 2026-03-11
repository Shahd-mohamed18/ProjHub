import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/utilts/chat_utils.dart';
import '../../models/message_model.dart';


part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تحميل قائمة المحادثات
  Stream<List<ChatUser>> getChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

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

            // جلب بيانات المستخدم الآخر
            try {
              DocumentSnapshot userDoc = await _firestore
                  .collection('users')
                  .doc(otherUserId)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                chatUsers.add(ChatUser(
                  userId: otherUserId,
                  name: userData['fullName'] ?? 'Unknown User',
                  photoUrl: userData['photoUrl'],
                  university: userData['university'],
                  lastMessage: lastMessage,
                  lastMessageTime: lastMessageTime,
                  isRead: isRead,
                  chatId: doc.id,
                ));
              }
            } catch (e) {
              print('Error fetching user data: $e');
            }
          }

          // ترتيب حسب آخر رسالة
          chatUsers.sort((a, b) {
            if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          return chatUsers;
        });
  }

  // تحميل رسائل محادثة معينة
  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final chatId = getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel.fromJson(data);
          }).toList();
        });
  }

  // إرسال رسالة
  Future<void> sendMessage(String otherUserId, String message) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || message.trim().isEmpty) return;

    final chatId = getChatId(currentUserId, otherUserId);

    try {
      // تحديث أو إنشاء المحادثة
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUserId, otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'readBy': [currentUserId],
      }, SetOptions(merge: true));

      // إضافة الرسالة
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
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Error sending message: $e',
      ));
    }
  }

  // تحديث حالة القراءة
  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final chatId = getChatId(currentUserId, otherUserId);

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({
            'readBy': FieldValue.arrayUnion([currentUserId]),
          });
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  // جلب بيانات مستخدم
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // مسح الرسائل
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }
}