// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:onboard/screens/chat_screen.dart';

// class ChatsScreen extends StatelessWidget {
//   const ChatsScreen({super.key});

//   Future<Map<String, dynamic>?> _getUserData(String userId) async {
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();

//       if (userDoc.exists) {
//         return userDoc.data() as Map<String, dynamic>;
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//     return null;
//   }

//   String _formatTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';

//     DateTime dateTime = timestamp.toDate();
//     DateTime now = DateTime.now();

//     if (dateTime.day == now.day &&
//         dateTime.month == now.month &&
//         dateTime.year == now.year) {
//       return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } else if (dateTime.day == now.day - 1 &&
//         dateTime.month == now.month &&
//         dateTime.year == now.year) {
//       return 'Yesterday';
//     } else {
//       return '${dateTime.day}/${dateTime.month}';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, authSnapshot) {
//         if (authSnapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final user = authSnapshot.data;
//         if (user == null) {
//           return const Scaffold(
//             body: Center(child: Text('User not logged in')),
//           );
//         }

//         final currentUserId = user.uid;

//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             automaticallyImplyLeading: false, // منع ظهور زر الرجوع
//             title: const Text(
//               'Messages',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           body: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color.fromARGB(255, 222, 233, 247),
//                   Colors.white,
//                   Color(0xff7E9FCA),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('chats')
//                   .where('users', arrayContains: currentUserId)
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
//                           size: 80,
//                           color: Colors.grey.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation with project owners',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final docs = snapshot.data!.docs;

//                 docs.sort((a, b) {
//                   final aTime = a['lastMessageTime'];
//                   final bTime = b['lastMessageTime'];

//                   if (aTime == null && bTime == null) return 0;
//                   if (aTime == null) return 1;
//                   if (bTime == null) return -1;

//                   return (bTime as Timestamp).compareTo(aTime as Timestamp);
//                 });

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final chatData = docs[index].data() as Map<String, dynamic>;
//                     final users = List<String>.from(chatData['users']);
//                     final otherUserId = users.firstWhere(
//                       (id) => id != currentUserId,
//                     );
//                     final lastMessage = chatData['lastMessage'] ?? '';
//                     final lastMessageTime =
//                         chatData['lastMessageTime'] as Timestamp?;
//                     final isRead =
//                         chatData['readBy']?.contains(currentUserId) ?? false;

//                     return FutureBuilder<Map<String, dynamic>?>(
//                       future: _getUserData(otherUserId),
//                       builder: (context, userSnapshot) {
//                         final userData = userSnapshot.data;
//                         final userName =
//                             userData?['fullName'] ?? 'Unknown User';

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             leading: Stack(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 28,
//                                   backgroundColor: Colors.grey.shade200,
//                                   child: Text(
//                                     userName.isNotEmpty
//                                         ? userName[0].toUpperCase()
//                                         : 'U',
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: Container(
//                                     width: 12,
//                                     height: 12,
//                                     decoration: BoxDecoration(
//                                       color: Colors.green,
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                         color: Colors.white,
//                                         width: 2,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             title: Text(
//                               userName,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             subtitle: Text(
//                               lastMessage,
//                               style: TextStyle(
//                                 color: isRead
//                                     ? Colors.grey.shade600
//                                     : Colors.black,
//                                 fontWeight: isRead
//                                     ? FontWeight.normal
//                                     : FontWeight.w500,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             trailing: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   _formatTime(lastMessageTime),
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: isRead
//                                         ? Colors.grey.shade500
//                                         : Colors.blue,
//                                     fontWeight: isRead
//                                         ? FontWeight.normal
//                                         : FontWeight.w500,
//                                   ),
//                                 ),
//                                 if (!isRead) ...[
//                                   const SizedBox(height: 4),
//                                   Container(
//                                     width: 8,
//                                     height: 8,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.blue,
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => ChatScreen(
//                                     otherUserId: otherUserId,
//                                     otherUserName: userName,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:onboard/cubits/chat/chat_cubit.dart';
// import 'package:onboard/screens/chatScreens/chat_screen.dart';
// import 'dart:io';

// class ChatsScreen extends StatelessWidget {
//   const ChatsScreen({super.key});

//   Widget _buildUserImage(String? photoUrl) {
//     if (photoUrl == null || photoUrl.isEmpty) {
//       return const Icon(Icons.person, size: 30, color: Colors.grey);
//     }

//     if (photoUrl.startsWith('http')) {
//       return ClipOval(
//         child: Image.network(
//           photoUrl,
//           width: 50,
//           height: 50,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => 
//               const Icon(Icons.person, size: 30, color: Colors.grey),
//         ),
//       );
//     }

//     if (photoUrl.startsWith('assets')) {
//       return ClipOval(
//         child: Image.asset(
//           photoUrl,
//           width: 50,
//           height: 50,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => 
//               const Icon(Icons.person, size: 30, color: Colors.grey),
//         ),
//       );
//     }

//     return ClipOval(
//       child: Image.file(
//         File(photoUrl),
//         width: 50,
//         height: 50,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => 
//             const Icon(Icons.person, size: 30, color: Colors.grey),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('Please login to view chats')),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Messages',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
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
//         child: BlocBuilder<ChatCubit, ChatState>(
//           builder: (context, state) {
//             return StreamBuilder<List<ChatUser>>(
//               stream: context.read<ChatCubit>().getChatsStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.chat_bubble_outline,
//                             size: 50,
//                             color: Color(0xff7E9FCA),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'No messages yet',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start a conversation with\nproject owners',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final chats = snapshot.data!;

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: chats.length,
//                   itemBuilder: (context, index) {
//                     final chat = chats[index];
                    
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.all(12),
//                         leading: Stack(
//                           children: [
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.grey.shade300,
//                                   width: 2,
//                                 ),
//                               ),
//                               child: _buildUserImage(chat.photoUrl),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 width: 14,
//                                 height: 14,
//                                 decoration: BoxDecoration(
//                                   color: Colors.green,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         title: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 chat.name,
//                                 style: TextStyle(
//                                   fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               chat.formattedTime,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: chat.isRead ? Colors.grey.shade500 : Colors.blue,
//                                 fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                         subtitle: Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 chat.lastMessage,
//                                 style: TextStyle(
//                                   color: chat.isRead ? Colors.grey.shade600 : Colors.black,
//                                   fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             if (!chat.isRead) ...[
//                               const SizedBox(width: 8),
//                               Container(
//                                 width: 10,
//                                 height: 10,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.blue,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ChatScreen(
//                                 otherUserId: chat.userId,
//                                 otherUserName: chat.name,
//                                 otherUserPhoto: chat.photoUrl,
//                                 otherUserUniversity: chat.university,
//                               ),
//                             ),
//                           ).then((_) {
//                             // تحديث حالة القراءة عند الرجوع
//                             context.read<ChatCubit>().markMessagesAsRead(chat.userId);
//                           });
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/cubits/chat/chat_cubit.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/screens/chatScreens/chat_screen.dart';
import 'dart:io';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  Widget _buildUserImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return const Icon(Icons.person, size: 30, color: Colors.grey);
    }

    if (photoUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => 
              const Icon(Icons.person, size: 30, color: Colors.grey),
        ),
      );
    }

    if (photoUrl.startsWith('assets')) {
      return ClipOval(
        child: Image.asset(
          photoUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => 
              const Icon(Icons.person, size: 30, color: Colors.grey),
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        File(photoUrl),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => 
            const Icon(Icons.person, size: 30, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Please login to view messages',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Messages',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
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
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return StreamBuilder<List<ChatUser>>(
                  stream: context.read<ChatCubit>().getChatsStream(),
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
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 50,
                                color: Color(0xff7E9FCA),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start a conversation with\nproject owners',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final chats = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Stack(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: _buildUserImage(chat.photoUrl),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.name,
                                    style: TextStyle(
                                      fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  chat.formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: chat.isRead ? Colors.grey.shade500 : Colors.blue,
                                    fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.lastMessage,
                                    style: TextStyle(
                                      color: chat.isRead ? Colors.grey.shade600 : Colors.black,
                                      fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!chat.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    otherUserId: chat.userId,
                                    otherUserName: chat.name,
                                    otherUserPhoto: chat.photoUrl,
                                    otherUserUniversity: chat.university,
                                  ),
                                ),
                              ).then((_) {
                                context.read<ChatCubit>().markMessagesAsRead(chat.userId);
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
