
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

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients && mounted) {
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
//       await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
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
//             'message': message,
//             'senderId': currentUserId,
//             'createdAt': FieldValue.serverTimestamp(),
//           });

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
//           'readBy': FieldValue.arrayUnion([currentUserId]),
//         })
//         .catchError((error) {
//           // تجاهل الخطأ إذا كان المستند غير موجود
//           print('Error marking as read: $error');
//         });
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
//               child: Text(
//                 widget.otherUserName.isNotEmpty
//                     ? widget.otherUserName[0].toUpperCase()
//                     : 'U',
//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
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
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromARGB(255, 222, 233, 247),
//               Colors.white,
//               Color(0xff7E9FCA),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('chats')
//                       .doc(chatId)
//                       .collection('messages')
//                       .orderBy('createdAt', descending: true)
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.chat_bubble_outline,
//                               size: 60,
//                               color: Colors.grey.shade400,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No messages yet',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Start the conversation',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.shade500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     try {
//                       _markMessagesAsRead(chatId);
//                     } catch (e) {
//                       // تجاهل الخطأ
//                     }

//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       _scrollToBottom();
//                     });

//                     return ListView.builder(
//                       controller: _scrollController,
//                       reverse: true,
//                       padding: const EdgeInsets.all(16),
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         final msgData =
//                             snapshot.data!.docs[index].data()
//                                 as Map<String, dynamic>;
//                         final msg = MessageModel.fromJson(msgData);

//                         return Column(
//                           crossAxisAlignment: msg.senderId == currentUserId
//                               ? CrossAxisAlignment.end
//                               : CrossAxisAlignment.start,
//                           children: [
//                             msg.senderId == currentUserId
//                                 ? ChatBubbleForFriend(message: msg)
//                                 : ChatBubble(message: msg),
//                             if (msg.createdAt != null)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 4,
//                                 ),
//                                 child: Text(
//                                   _formatTime(msg.createdAt),
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey.shade500,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),

//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xffF0F0F0),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: InputDecoration(
//                           hintText: 'Type a message...',
//                           hintStyle: TextStyle(color: Colors.grey.shade400),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     decoration: const BoxDecoration(
//                       color: Color(0xff314F6A),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: _sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:onboard/cubits/chat/chat_cubit.dart';
// import 'package:onboard/models/message_model.dart';
// import 'package:onboard/widgets/chat_bubble.dart';

// class ChatScreen extends StatefulWidget {
//   final String otherUserId;
//   final String otherUserName;
//   final String? otherUserPhoto;
//   final String? otherUserUniversity;

//   const ChatScreen({
//     super.key,
//     required this.otherUserId,
//     required this.otherUserName,
//     this.otherUserPhoto,
//     this.otherUserUniversity,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   void initState() {
//     super.initState();
//     // تحديث حالة القراءة عند فتح الشات
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ChatCubit>().markMessagesAsRead(widget.otherUserId);
//     });
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

//   String _formatTime(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }

//   Widget _buildUserImage() {
//     final photoUrl = widget.otherUserPhoto;
    
//     if (photoUrl == null || photoUrl.isEmpty) {
//       return Container(
//         width: 40,
//         height: 40,
//         decoration: const BoxDecoration(
//           color: Color(0xff314F6A),
//           shape: BoxShape.circle,
//         ),
//         child: const Center(
//           child: Text(
//             'U',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       );
//     }

//     if (photoUrl.startsWith('http')) {
//       return CircleAvatar(
//         radius: 20,
//         backgroundImage: NetworkImage(photoUrl),
//         child: Container(), // لتجنب الخطأ
//       );
//     }

//     if (photoUrl.startsWith('assets')) {
//       return CircleAvatar(
//         radius: 20,
//         backgroundImage: AssetImage(photoUrl),
//         child: Container(),
//       );
//     }

//     return CircleAvatar(
//       radius: 20,
//       backgroundImage: FileImage(File(photoUrl)),
//       child: Container(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
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
//             _buildUserImage(),
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
//                   if (widget.otherUserUniversity != null && widget.otherUserUniversity!.isNotEmpty)
//                     Text(
//                       widget.otherUserUniversity!,
//                       style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromARGB(255, 222, 233, 247),
//               Colors.white,
//               Color(0xff7E9FCA),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder<List<MessageModel>>(
//                 stream: context.read<ChatCubit>().getMessagesStream(widget.otherUserId),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   blurRadius: 8,
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.chat_bubble_outline,
//                               size: 40,
//                               color: Color(0xff7E9FCA),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'No messages yet',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Say hello to start the conversation',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   final messages = snapshot.data!;
                  
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     _scrollToBottom();
//                   });

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true,
//                     padding: const EdgeInsets.all(16),
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final msg = messages[index];
//                       final isMe = msg.senderId == currentUserId;

//                       return Column(
//                         crossAxisAlignment: isMe
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             margin: EdgeInsets.only(
//                               left: isMe ? 50 : 10,
//                               right: isMe ? 10 : 50,
//                               bottom: 4,
//                             ),
//                             child: ChatBubble(
//                               message: msg,
//                               isMe: isMe,
//                             ),
//                           ),
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
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 5,
//                     offset: const Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xffF0F0F0),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: TextField(
//                         controller: _messageController,
//                         decoration: InputDecoration(
//                           hintText: 'Type a message...',
//                           hintStyle: TextStyle(color: Colors.grey.shade400),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     decoration: const BoxDecoration(
//                       color: Color(0xff314F6A),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.send,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: _sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final message = _messageController.text.trim();
//     _messageController.clear();

//     await context.read<ChatCubit>().sendMessage(widget.otherUserId, message);
//     _scrollToBottom();
//   }
// }




import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/cubits/chat/chat_cubit.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/models/message_model.dart';
import 'package:onboard/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;
  final String? otherUserUniversity;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    this.otherUserUniversity,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState.userModel != null) {
      setState(() {
        currentUserId = authState.userModel!.uid;
      });
      context.read<ChatCubit>().markMessagesAsRead(widget.otherUserId);
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildUserImage() {
    final photoUrl = widget.otherUserPhoto;
    
    if (photoUrl == null || photoUrl.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xff314F6A),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'U',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (photoUrl.startsWith('http')) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    if (photoUrl.startsWith('assets')) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(photoUrl),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundImage: FileImage(File(photoUrl)),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUserId == null) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    await context.read<ChatCubit>().sendMessage(widget.otherUserId, message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            _buildUserImage(),
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
                  if (widget.otherUserUniversity != null && widget.otherUserUniversity!.isNotEmpty)
                    Text(
                      widget.otherUserUniversity!,
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
              child: StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatCubit>().getMessagesStream(widget.otherUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 40,
                              color: Color(0xff7E9FCA),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Say hello to start the conversation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = snapshot.data!;
                  
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;

                      return Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: isMe ? 50 : 10,
                              right: isMe ? 10 : 50,
                              bottom: 4,
                            ),
                            child: ChatBubble(
                              message: msg,
                              isMe: isMe,
                            ),
                          ),
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