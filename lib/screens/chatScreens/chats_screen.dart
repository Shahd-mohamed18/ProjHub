// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:onboard/cubits/chat/chat_cubit.dart';
// import 'package:onboard/cubits/auth/auth_cubit.dart';
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
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, authState) {
//         if (authState.status != AuthStatus.authenticated) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Please login to view messages',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
//                     child: const Text('Go to Login'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             automaticallyImplyLeading: false,
//             title: const Text(
//               'Messages',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 28,
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
//             child: BlocBuilder<ChatCubit, ChatState>(
//               builder: (context, state) {
//                 return StreamBuilder<List<ChatUser>>(
//                   stream: context.read<ChatCubit>().getChatsStream(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }

//                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.2),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.chat_bubble_outline,
//                                 size: 50,
//                                 color: Color(0xff7E9FCA),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             const Text(
//                               'No messages yet',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Start a conversation with\nproject owners',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     final chats = snapshot.data!;

//                     return ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: chats.length,
//                       itemBuilder: (context, index) {
//                         final chat = chats[index];

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.all(12),
//                             leading: Stack(
//                               children: [
//                                 Container(
//                                   width: 60,
//                                   height: 60,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.grey.shade300,
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: _buildUserImage(chat.photoUrl),
//                                 ),
//                                 Positioned(
//                                   bottom: 0,
//                                   right: 0,
//                                   child: Container(
//                                     width: 14,
//                                     height: 14,
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
//                             title: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     chat.name,
//                                     style: TextStyle(
//                                       fontWeight: chat.isRead ? FontWeight.normal : FontWeight.bold,
//                                       fontSize: 16,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   chat.formattedTime,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: chat.isRead ? Colors.grey.shade500 : Colors.blue,
//                                     fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             subtitle: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     chat.lastMessage,
//                                     style: TextStyle(
//                                       color: chat.isRead ? Colors.grey.shade600 : Colors.black,
//                                       fontWeight: chat.isRead ? FontWeight.normal : FontWeight.w500,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 if (!chat.isRead) ...[
//                                   const SizedBox(width: 8),
//                                   Container(
//                                     width: 10,
//                                     height: 10,
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
//                                     otherUserId: chat.userId,
//                                     otherUserName: chat.name,
//                                     otherUserPhoto: chat.photoUrl,
//                                     otherUserUniversity: chat.university,
//                                   ),
//                                 ),
//                               ).then((_) {
//                                 context.read<ChatCubit>().markMessagesAsRead(chat.userId);
//                               });
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
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Please login to view messages',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
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
                                      fontWeight: chat.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  chat.formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: chat.isRead
                                        ? Colors.grey.shade500
                                        : Colors.blue,
                                    fontWeight: chat.isRead
                                        ? FontWeight.normal
                                        : FontWeight.w500,
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
                                      color: chat.isRead
                                          ? Colors.grey.shade600
                                          : Colors.black,
                                      fontWeight: chat.isRead
                                          ? FontWeight.normal
                                          : FontWeight.w500,
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
                                // ✅ إضافة if (context.mounted) هنا
                                if (context.mounted) {
                                  context.read<ChatCubit>().markMessagesAsRead(
                                    chat.userId,
                                  );
                                }
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
