// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:onboard/models/message_model.dart';
// import 'package:onboard/utilts/chat_utils.dart';
// import 'package:onboard/widgets/chat_bubble.dart';

// class ChatScreen extends StatefulWidget {
//   final String otherUserId;
//   final String otherUserName;

//   const ChatScreen({
//     super.key,
//     required this.otherUserId,
//     required this.otherUserName,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final chatId = getChatId(currentUserId, widget.otherUserId);
//     final message = _messageController.text.trim();

//     try {
//       // تحديث آخر رسالة في المحادثة
//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .set({
//         'users': [currentUserId, widget.otherUserId],
//         'lastMessage': message,
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         'readBy': [currentUserId], // المرأ قرأ الرسالة
//       }, SetOptions(merge: true));

//       // إضافة الرسالة
//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .add({
//         'message': message,
//         'senderId': currentUserId,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error sending message: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // تحديث حالة قراءة الرسائل
//   void _markMessagesAsRead(String chatId) {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .update({
//       'readBy': FieldValue.arrayUnion([currentUserId])
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatId = getChatId(currentUserId, widget.otherUserId);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundColor: Colors.grey.shade200,
//               backgroundImage: null, // يمكن إضافة صورة المستخدم هنا
//               child: const Icon(Icons.person, size: 20, color: Colors.grey),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.otherUserName,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Text(
//                   'Online',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .doc(chatId)
//                   .collection('messages')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.chat_bubble_outline,
//                           size: 60,
//                           color: Colors.grey.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start the conversation',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // تحديث حالة القراءة
//                 _markMessagesAsRead(chatId);

//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollToBottom();
//                 });

//                 return ListView.builder(
//                   controller: _scrollController,
//                   reverse: true,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final msgData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
//                     final msg = MessageModel.fromJson(msgData);

//                     // إضافة الوقت للرسالة
//                     return Container(
//                       margin: const EdgeInsets.symmetric(vertical: 4),
//                       child: Column(
//                         crossAxisAlignment: msg.senderId == currentUserId
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           msg.senderId == currentUserId
//                               ? ChatBubbleForFriend(message: msg)
//                               : ChatBubble(message: msg),
//                           if (msg.createdAt != null)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               child: Text(
//                                 _formatTime(msg.createdAt),
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey.shade500,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // حقل إدخال الرسالة
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       hintStyle: TextStyle(color: Colors.grey.shade400),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                     ),
//                     maxLines: null,
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: Color(0xff314F6A),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white),
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTime(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }
// }

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:onboard/models/message_model.dart';
// import 'package:onboard/utilts/chat_utils.dart';
// import 'package:onboard/widgets/chat_bubble.dart';

// class ChatScreen extends StatefulWidget {
//   final String otherUserId;
//   final String otherUserName;

//   const ChatScreen({
//     super.key,
//     required this.otherUserId,
//     required this.otherUserName,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   Map<String, dynamic>? _otherUserData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOtherUserData();
//   }

//   Future<void> _fetchOtherUserData() async {
//     try {
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.otherUserId)
//           .get();

//       if (doc.exists && mounted) {
//         setState(() {
//           _otherUserData = doc.data() as Map<String, dynamic>;
//         });
//       }
//     } catch (e) {
//       print('Error fetching other user data: $e');
//     }
//   }

//   ImageProvider _getImageProvider(String? path) {
//     if (path == null || path.isEmpty) {
//       return const AssetImage('assets/images/default_avatar.png');
//     }
//     if (path.startsWith('http')) {
//       return NetworkImage(path);
//     } else {
//       try {
//         final file = File(path);
//         if (file.existsSync()) {
//           return FileImage(file);
//         }
//       } catch (e) {
//         print('Error loading image: $e');
//       }
//       return const AssetImage('assets/images/default_avatar.png');
//     }
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final chatId = getChatId(currentUserId, widget.otherUserId);
//     final message = _messageController.text.trim();

//     try {
//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .set({
//         'users': [currentUserId, widget.otherUserId],
//         'lastMessage': message,
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         'readBy': [currentUserId],
//       }, SetOptions(merge: true));

//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .add({
//         'message': message,
//         'senderId': currentUserId,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error sending message: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _markMessagesAsRead(String chatId) {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .update({
//       'readBy': FieldValue.arrayUnion([currentUserId])
//     });
//   }

//   String _formatTime(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatId = getChatId(currentUserId, widget.otherUserId);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: _getImageProvider(_otherUserData?['photoUrl']),
//               backgroundColor: Colors.grey.shade200,
//               child: _otherUserData?['photoUrl'] == null
//                   ? Text(
//                       widget.otherUserName.isNotEmpty
//                           ? widget.otherUserName[0].toUpperCase()
//                           : 'U',
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.otherUserName,
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     _otherUserData?['university'] ?? '',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               color: const Color(0xffF5F5F5), // خلفية رمادية فاتحة للمحادثة
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('chats')
//                     .doc(chatId)
//                     .collection('messages')
//                     .orderBy('createdAt', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.chat_bubble_outline,
//                             size: 60,
//                             color: Colors.grey.shade400,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'No messages yet',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Start the conversation',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   _markMessagesAsRead(chatId);

//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     _scrollToBottom();
//                   });

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true,
//                     padding: const EdgeInsets.all(16),
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       final msgData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
//                       final msg = MessageModel.fromJson(msgData);

//                       return Column(
//                         crossAxisAlignment: msg.senderId == currentUserId
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           msg.senderId == currentUserId
//                               ? ChatBubbleForFriend(message: msg)
//                               : ChatBubble(message: msg),
//                           if (msg.createdAt != null)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 4,
//                               ),
//                               child: Text(
//                                 _formatTime(msg.createdAt),
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey.shade500,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),

//           // حقل إدخال الرسالة
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 5,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xffF0F0F0),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: 'Type a message...',
//                         hintStyle: TextStyle(color: Colors.grey.shade400),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 12,
//                         ),
//                       ),
//                       maxLines: null,
//                       textInputAction: TextInputAction.send,
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: Color(0xff314F6A),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.send, color: Colors.white, size: 20),
//                     onPressed: _sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onboard/models/message_model.dart';
import 'package:onboard/utilts/chat_utils.dart';

import 'package:onboard/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? _otherUserData;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserData();
  }

  Future<void> _fetchOtherUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _otherUserData = doc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print('Error fetching other user data: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatId = getChatId(currentUserId, widget.otherUserId);
    final message = _messageController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'users': [currentUserId, widget.otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'readBy': [currentUserId],
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'message': message,
            'senderId': currentUserId,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markMessagesAsRead(String chatId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .update({
          'readBy': FieldValue.arrayUnion([currentUserId]),
        })
        .catchError((error) {
          // تجاهل الخطأ إذا كان المستند غير موجود
          print('Error marking as read: $error');
        });
  }

  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(currentUserId, widget.otherUserId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _otherUserData?['university'] ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 222, 233, 247),
              Colors.white,
              Color(0xff7E9FCA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    try {
                      _markMessagesAsRead(chatId);
                    } catch (e) {
                      // تجاهل الخطأ
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final msgData =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        final msg = MessageModel.fromJson(msgData);

                        return Column(
                          crossAxisAlignment: msg.senderId == currentUserId
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            msg.senderId == currentUserId
                                ? ChatBubbleForFriend(message: msg)
                                : ChatBubble(message: msg),
                            if (msg.createdAt != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  _formatTime(msg.createdAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF0F0F0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff314F6A),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
