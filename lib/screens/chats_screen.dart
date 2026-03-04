
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:onboard/screens/chat_screen.dart';

// class ChatsScreen extends StatelessWidget {
//   ChatsScreen({super.key});

//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   // دالة لجلب اسم المستخدم من الـ Firestore
//   Future<String> _getUserName(String userId) async {
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();
      
//       if (userDoc.exists) {
//         return userDoc['fullName'] ?? 'Unknown User';
//       }
//     } catch (e) {
//       print('Error fetching user name: $e');
//     }
//     return 'Unknown User';
//   }

//   // دالة لتنسيق الوقت
//   String _formatTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';
    
//     DateTime dateTime = timestamp.toDate();
//     DateTime now = DateTime.now();
    
//     // إذا كان اليوم هو نفس اليوم
//     if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
//       return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//     }
//     // إذا كان الأمس
//     else if (dateTime.day == now.day - 1 && dateTime.month == now.month && dateTime.year == now.year) {
//       return 'Yesterday';
//     }
//     // غير ذلك
//     else {
//       return '${dateTime.day}/${dateTime.month}';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Messages',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('chats')
//             .where('users', arrayContains: currentUserId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.chat_bubble_outline,
//                     size: 80,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No messages yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Start a conversation with project owners',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final docs = snapshot.data!.docs;
          
//           // ترتيب المحادثات حسب آخر رسالة
//           docs.sort((a, b) {
//             final aTime = a['lastMessageTime'];
//             final bTime = b['lastMessageTime'];

//             if (aTime == null && bTime == null) return 0;
//             if (aTime == null) return 1;
//             if (bTime == null) return -1;

//             return (bTime as Timestamp).compareTo(aTime as Timestamp);
//           });

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final chatData = docs[index].data() as Map<String, dynamic>;
//               final users = List<String>.from(chatData['users']);
//               final otherUserId = users.firstWhere((id) => id != currentUserId);
//               final lastMessage = chatData['lastMessage'] ?? '';
//               final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
//               final isRead = chatData['readBy']?.contains(currentUserId) ?? false;

//               return FutureBuilder<String>(
//                 future: _getUserName(otherUserId),
//                 builder: (context, nameSnapshot) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       leading: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.grey.shade200,
//                             backgroundImage: null, // يمكن إضافة صورة المستخدم هنا
//                             child: const Icon(
//                               Icons.person,
//                               size: 30,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           // دائرة الحالة (أونلاين/أوفلاين)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Colors.green,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       title: Text(
//                         nameSnapshot.data ?? 'Loading...',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       subtitle: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               lastMessage,
//                               style: TextStyle(
//                                 color: isRead ? Colors.grey.shade600 : Colors.black,
//                                 fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             _formatTime(lastMessageTime),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isRead ? Colors.grey.shade500 : Colors.blue,
//                               fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
//                             ),
//                           ),
//                           if (!isRead) ...[
//                             const SizedBox(height: 4),
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: const BoxDecoration(
//                                 color: Colors.blue,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ChatScreen(
//                               otherUserId: otherUserId,
//                               otherUserName: nameSnapshot.data ?? 'User',
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:onboard/screens/chat_screen.dart';

// class ChatsScreen extends StatelessWidget {
//   ChatsScreen({super.key});

//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

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

//   String _formatTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';
    
//     DateTime dateTime = timestamp.toDate();
//     DateTime now = DateTime.now();
    
//     if (dateTime.day == now.day && 
//         dateTime.month == now.month && 
//         dateTime.year == now.year) {
//       return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } else if (dateTime.day == now.day - 1 && 
//                dateTime.month == now.month && 
//                dateTime.year == now.year) {
//       return 'Yesterday';
//     } else {
//       return '${dateTime.day}/${dateTime.month}';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Messages',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('chats')
//             .where('users', arrayContains: currentUserId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.chat_bubble_outline,
//                     size: 80,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No messages yet',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Start a conversation with project owners',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final docs = snapshot.data!.docs;
          
//           docs.sort((a, b) {
//             final aTime = a['lastMessageTime'];
//             final bTime = b['lastMessageTime'];

//             if (aTime == null && bTime == null) return 0;
//             if (aTime == null) return 1;
//             if (bTime == null) return -1;

//             return (bTime as Timestamp).compareTo(aTime as Timestamp);
//           });

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final chatData = docs[index].data() as Map<String, dynamic>;
//               final users = List<String>.from(chatData['users']);
//               final otherUserId = users.firstWhere((id) => id != currentUserId);
//               final lastMessage = chatData['lastMessage'] ?? '';
//               final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
//               final isRead = chatData['readBy']?.contains(currentUserId) ?? false;

//               return FutureBuilder<Map<String, dynamic>?>(
//                 future: _getUserData(otherUserId),
//                 builder: (context, userSnapshot) {
//                   final userData = userSnapshot.data;
//                   final userName = userData?['fullName'] ?? 'Unknown User';
//                   final userPhoto = userData?['photoUrl'];

//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       leading: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 28,
//                             backgroundColor: Colors.grey.shade200,
//                             backgroundImage: userPhoto != null 
//                                 ? _getImageProvider(userPhoto)
//                                 : null,
//                             child: userPhoto == null
//                                 ? Text(
//                                     userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   )
//                                 : null,
//                           ),
//                           // دائرة الحالة (أونلاين/أوفلاين)
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Colors.green,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       title: Text(
//                         userName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       subtitle: Text(
//                         lastMessage,
//                         style: TextStyle(
//                           color: isRead ? Colors.grey.shade600 : Colors.black,
//                           fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             _formatTime(lastMessageTime),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isRead ? Colors.grey.shade500 : Colors.blue,
//                               fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
//                             ),
//                           ),
//                           if (!isRead) ...[
//                             const SizedBox(height: 4),
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: const BoxDecoration(
//                                 color: Colors.blue,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ChatScreen(
//                               otherUserId: otherUserId,
//                               otherUserName: userName,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onboard/screens/chat_screen.dart';

class ChatsScreen extends StatelessWidget {
  ChatsScreen({super.key});

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    
    if (dateTime.day == now.day && 
        dateTime.month == now.month && 
        dateTime.year == now.year) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.day == now.day - 1 && 
               dateTime.month == now.month && 
               dateTime.year == now.year) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: currentUserId)
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
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No messages yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation with project owners',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs;
            
            docs.sort((a, b) {
              final aTime = a['lastMessageTime'];
              final bTime = b['lastMessageTime'];

              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;

              return (bTime as Timestamp).compareTo(aTime as Timestamp);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final chatData = docs[index].data() as Map<String, dynamic>;
                final users = List<String>.from(chatData['users']);
                final otherUserId = users.firstWhere((id) => id != currentUserId);
                final lastMessage = chatData['lastMessage'] ?? '';
                final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
                final isRead = chatData['readBy']?.contains(currentUserId) ?? false;

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _getUserData(otherUserId),
                  builder: (context, userSnapshot) {
                    final userData = userSnapshot.data;
                    final userName = userData?['fullName'] ?? 'Unknown User';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
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
                        title: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          style: TextStyle(
                            color: isRead ? Colors.grey.shade600 : Colors.black,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(lastMessageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: isRead ? Colors.grey.shade500 : Colors.blue,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
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
                                otherUserId: otherUserId,
                                otherUserName: userName,
                              ),
                            ),
                          );
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
  }
}