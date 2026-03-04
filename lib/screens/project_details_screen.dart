// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/project_model.dart';
// import 'package:open_file/open_file.dart';

// class ProjectDetailsScreen extends StatefulWidget {
//   final Project project;

//   const ProjectDetailsScreen({super.key, required this.project});

//   @override
//   State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
// }

// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   int _currentImageIndex = 0;
//   final PageController _pageController = PageController();

//   // دالة لتحديد نوع الصورة
//   ImageProvider _getImageProvider(String path) {
//     if (path.startsWith('http')) {
//       return NetworkImage(path);
//     } else {
//       return FileImage(File(path));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     final bool isOwner = currentUser?.uid == widget.project.authorId;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // Sliver App Bar مع الصور
//           SliverAppBar(
//             expandedHeight: 500,
//             pinned: true,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             flexibleSpace: FlexibleSpaceBar(
//               background: widget.project.images.isNotEmpty
//                   ? Stack(
//                       children: [
//                         // PageView للصور
//                         PageView.builder(
//                           controller: _pageController,
//                           itemCount: widget.project.images.length,
//                           onPageChanged: (index) {
//                             setState(() {
//                               _currentImageIndex = index;
//                             });
//                           },
//                           itemBuilder: (context, index) {
//                             return Image(
//                               image: _getImageProvider(
//                                 widget.project.images[index],
//                               ),
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey.shade200,
//                                   child: const Center(
//                                     child: Icon(
//                                       Icons.broken_image,
//                                       size: 50,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),

//                         // مؤشر الصور
//                         if (widget.project.images.length > 1)
//                           Positioned(
//                             bottom: 16,
//                             right: 16,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.6),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 '${_currentImageIndex + 1}/${widget.project.images.length}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     )
//                   : Container(
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: Icon(Icons.image, size: 80, color: Colors.grey),
//                       ),
//                     ),
//             ),
//           ),

//           // محتوى المشروع
//           SliverToBoxAdapter(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromARGB(255, 222, 233, 247),
//                     Colors.white,
//                     Color(0xff7E9FCA),
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // عنوان المشروع
//                     Text(
//                       widget.project.title,
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // معلومات المؤلف
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundImage:
//                                 widget.project.authorPhotoUrl.isNotEmpty
//                                 ? (widget.project.authorPhotoUrl.startsWith(
//                                         'http',
//                                       )
//                                       ? NetworkImage(
//                                           widget.project.authorPhotoUrl,
//                                         )
//                                       : FileImage(
//                                               File(
//                                                 widget.project.authorPhotoUrl,
//                                               ),
//                                             )
//                                             as ImageProvider)
//                                 : null,
//                             child: widget.project.authorPhotoUrl.isEmpty
//                                 ? const Icon(Icons.person, size: 25)
//                                 : null,
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   widget.project.authorName,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 Text(
//                                   widget.project.authorEmail,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                                 if (isOwner)
//                                   Container(
//                                     margin: const EdgeInsets.only(top: 4),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 2,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue.shade50,
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: const Text(
//                                       'Owner',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.blue,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // الوصف
//                     const Text(
//                       'Description',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       widget.project.description,
//                       style: const TextStyle(fontSize: 16, height: 1.6),
//                     ),
//                     const SizedBox(height: 24),

//                     // Tags
//                     const Text(
//                       'Tags',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 12,
//                       runSpacing: 8,
//                       children: widget.project.tags.map((tag) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: Text(
//                             tag,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 24),

//                     // Category
//                     if (widget.project.category.isNotEmpty) ...[
//                       const Text(
//                         'Category',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xff7E9FCA).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           widget.project.category,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                     ],

//                     // Document button
//                     if (widget.project.documentUrl.isNotEmpty)
//                       Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.only(bottom: 24),
//                         child: ElevatedButton.icon(
//                           onPressed: () async {
//                             // فتح الملف المحلي
//                             try {
//                               final result = await OpenFile.open(
//                                 widget.project.documentUrl,
//                               );

//                               if (result.type == ResultType.error) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Error opening file: ${result.message}',
//                                     ),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                               }
//                             } catch (e) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Error: $e'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             }
//                           },
//                           icon: const Icon(Icons.picture_as_pdf),
//                           label: const Text('View Documentation'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red.shade700,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),

//                     // Thumbnails للمشاريع الأخرى
//                     if (widget.project.images.length > 1) ...[
//                       const Text(
//                         'All Images',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         height: 80,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: widget.project.images.length,
//                           itemBuilder: (context, index) {
//                             return GestureDetector(
//                               onTap: () {
//                                 _pageController.animateToPage(
//                                   index,
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeInOut,
//                                 );
//                               },
//                               child: Container(
//                                 width: 80,
//                                 height: 80,
//                                 margin: const EdgeInsets.only(right: 8),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: _currentImageIndex == index
//                                         ? Colors.blue
//                                         : Colors.grey.shade300,
//                                     width: 2,
//                                   ),
//                                   image: DecorationImage(
//                                     image: _getImageProvider(
//                                       widget.project.images[index],
//                                     ),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:onboard/screens/chat_screen.dart';
// import '../models/project_model.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ProjectDetailsScreen extends StatefulWidget {
//   final Project project;

//   const ProjectDetailsScreen({super.key, required this.project});

//   @override
//   State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
// }

// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   final PageController _pageController = PageController();
//   int _currentImageIndex = 0;
//   Map<String, dynamic>? _authorData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAuthorData();
//   }

//   Future<void> _fetchAuthorData() async {
//     try {
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.project.authorId)
//           .get();

//       if (doc.exists) {
//         setState(() {
//           _authorData = doc.data() as Map<String, dynamic>;
//         });
//       }
//     } catch (e) {
//       print('Error fetching author data: $e');
//     }
//   }

//   ImageProvider _getImageProvider(String path) {
//     if (path.startsWith('http')) {
//       return NetworkImage(path);
//     } else {
//       return FileImage(File(path));
//     }
//   }

//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       throw Exception('Could not launch $url');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.project.title),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.black),
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
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ===== معرض الصور مع PageView للتمرير =====
//               if (widget.project.images.isNotEmpty) ...[
//                 Container(
//                   height: 300,
//                   color: Colors.grey.shade100,
//                   child: Stack(
//                     children: [
//                       // PageView للتمرير بين الصور
//                       PageView.builder(
//                         controller: _pageController,
//                         itemCount: widget.project.images.length,
//                         onPageChanged: (index) {
//                           setState(() {
//                             _currentImageIndex = index;
//                           });
//                         },
//                         itemBuilder: (context, index) {
//                           return Image(
//                             image: _getImageProvider(
//                               widget.project.images[index],
//                             ),
//                             fit: BoxFit.contain,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.broken_image,
//                                       size: 50,
//                                       color: Colors.grey.shade400,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Failed to load image',
//                                       style: TextStyle(
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),

//                       // مؤشر رقم الصورة
//                       Positioned(
//                         bottom: 16,
//                         right: 16,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.6),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             '${_currentImageIndex + 1}/${widget.project.images.length}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),

//                       // أزرار التنقل
//                       if (widget.project.images.length > 1) ...[
//                         Positioned(
//                           left: 8,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: IconButton(
//                               icon: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_back_ios,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                               onPressed: () {
//                                 if (_currentImageIndex > 0) {
//                                   _pageController.previousPage(
//                                     duration: const Duration(milliseconds: 300),
//                                     curve: Curves.easeInOut,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           right: 8,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: IconButton(
//                               icon: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                               onPressed: () {
//                                 if (_currentImageIndex <
//                                     widget.project.images.length - 1) {
//                                   _pageController.nextPage(
//                                     duration: const Duration(milliseconds: 300),
//                                     curve: Curves.easeInOut,
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // الصور المصغرة
//                 if (widget.project.images.length > 1)
//                   Container(
//                     height: 70,
//                     padding: const EdgeInsets.all(8),
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: widget.project.images.length,
//                       itemBuilder: (context, index) {
//                         return GestureDetector(
//                           onTap: () {
//                             _pageController.animateToPage(
//                               index,
//                               duration: const Duration(milliseconds: 300),
//                               curve: Curves.easeInOut,
//                             );
//                           },
//                           child: Container(
//                             width: 70,
//                             margin: const EdgeInsets.only(right: 8),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: _currentImageIndex == index
//                                     ? Colors.blue
//                                     : Colors.grey.shade300,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                               image: DecorationImage(
//                                 image: _getImageProvider(
//                                   widget.project.images[index],
//                                 ),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             child: _currentImageIndex == index
//                                 ? Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue.withOpacity(0.2),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: const Center(
//                                       child: Icon(
//                                         Icons.check_circle,
//                                         color: Colors.blue,
//                                         size: 20,
//                                       ),
//                                     ),
//                                   )
//                                 : null,
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                 const SizedBox(height: 16),
//               ],

//               // ===== محتوى المشروع =====
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // العنوان
//                     Text(
//                       widget.project.title,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     // معلومات المؤلف - مع بيانات حقيقية من Firestore
//                     // Row(
//                     //   children: [
//                     //     CircleAvatar(
//                     //       radius: 16,
//                     //       backgroundImage: _authorData?['photoUrl'] != null
//                     //           ? (_authorData!['photoUrl'].toString().startsWith(
//                     //                   'http',
//                     //                 )
//                     //                 ? NetworkImage(_authorData!['photoUrl'])
//                     //                 : FileImage(File(_authorData!['photoUrl']))
//                     //                       as ImageProvider)
//                     //           : null,
//                     //       child: _authorData?['photoUrl'] == null
//                     //           ? const Icon(Icons.person, size: 16)
//                     //           : null,
//                     //     ),
//                     //     const SizedBox(width: 8),
//                     //     Expanded(
//                     //       child: Column(
//                     //         crossAxisAlignment: CrossAxisAlignment.start,
//                     //         children: [
//                     //           Text(
//                     //             _authorData?['fullName'] ??
//                     //                 widget.project.authorName,
//                     //             style: const TextStyle(
//                     //               fontSize: 16,
//                     //               fontWeight: FontWeight.w600,
//                     //             ),
//                     //           ),
//                     //           Text(
//                     //             _authorData?['university'] ?? '',
//                     //             style: TextStyle(
//                     //               fontSize: 12,
//                     //               color: Colors.grey.shade600,
//                     //             ),
//                     //           ),
//                     //         ],
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),

//                     // // بعد معلومات المؤلف (بعد الـ Row بتاع المؤلف)
//                     // const SizedBox(height: 16),

//                     // // زر المحادثة مع صاحب المشروع
//                     // if (FirebaseAuth.instance.currentUser?.uid !=
//                     //     widget.project.authorId)
//                     //   ElevatedButton.icon(
//                     //     onPressed: () {
//                     //       Navigator.push(
//                     //         context,
//                     //         MaterialPageRoute(
//                     //           builder: (context) => ChatScreen(
//                     //             otherUserId: widget.project.authorId,
//                     //             otherUserName:
//                     //                 _authorData?['fullName'] ??
//                     //                 widget.project.authorName,
//                     //           ),
//                     //         ),
//                     //       );
//                     //     },
//                     //     icon: const Icon(Icons.chat),
//                     //     label: const Text('Chat with the owner'),
//                     //     style: ElevatedButton.styleFrom(
//                     //       backgroundColor: const Color(0xff314F6A),
//                     //       foregroundColor: Colors.white,
//                     //       minimumSize: const Size(double.infinity, 50),
//                     //       shape: RoundedRectangleBorder(
//                     //         borderRadius: BorderRadius.circular(12),
//                     //       ),
//                     //     ),
//                     //   ),

//                     // في قسم معلومات المؤلف، استبدل الـ Row بهذا الكود:

//                     // معلومات المؤلف - مع بيانات حقيقية من Firestore
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundImage: _authorData?['photoUrl'] != null
//                                 ? (_authorData!['photoUrl']
//                                           .toString()
//                                           .startsWith('http')
//                                       ? NetworkImage(_authorData!['photoUrl'])
//                                       : FileImage(
//                                               File(_authorData!['photoUrl']),
//                                             )
//                                             as ImageProvider)
//                                 : null,
//                             child: _authorData?['photoUrl'] == null
//                                 ? const Icon(Icons.person, size: 25)
//                                 : null,
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _authorData?['fullName'] ??
//                                       widget.project.authorName,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 Text(
//                                   _authorData?['university'] ?? '',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // زر المحادثة - يظهر فقط إذا كان المستخدم ليس صاحب المشروع
//                           if (FirebaseAuth.instance.currentUser?.uid !=
//                               widget.project.authorId)
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xff314F6A),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: IconButton(
//                                 icon: const Icon(
//                                   Icons.chat,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => ChatScreen(
//                                         otherUserId: widget.project.authorId,
//                                         otherUserName:
//                                             _authorData?['fullName'] ??
//                                             widget.project.authorName,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // التصنيف
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         widget.project.category,
//                         style: TextStyle(
//                           color: Colors.blue.shade700,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // الوصف
//                     const Text(
//                       'Description',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       widget.project.description,
//                       style: const TextStyle(fontSize: 16, height: 1.5),
//                     ),
//                     const SizedBox(height: 16),

//                     // Tags
//                     const Text(
//                       'Tags',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       children: widget.project.tags.map((tag) {
//                         return Chip(
//                           label: Text(tag),
//                           backgroundColor: Colors.grey.shade100,
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 16),

//                     // GitHub Link
//                     if (widget.project.githubUrl.isNotEmpty)
//                       Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.only(bottom: 16),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'GitHub Repository',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             InkWell(
//                               onTap: () => _launchURL(widget.project.githubUrl),
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.code, color: Colors.blue),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       widget.project.githubUrl,
//                                       style: const TextStyle(
//                                         color: Colors.blue,
//                                         decoration: TextDecoration.underline,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   const Icon(
//                                     Icons.open_in_new,
//                                     size: 16,
//                                     color: Colors.grey,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     // Document
//                     if (widget.project.documentUrl.isNotEmpty)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.description,
//                               color: Colors.blue,
//                               size: 30,
//                             ),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Project Document',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Tap to view PDF',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.download),
//                               onPressed: () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Opening document...'),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboard/screens/chat_screen.dart';
import '../models/project_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Map<String, dynamic>? _authorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAuthorData();
  }

  Future<void> _fetchAuthorData() async {
    if (!mounted) return;
    
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.project.authorId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _authorData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching author data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImage(String path) {
    // التحقق من أن الصورة موجودة
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // مسار محلي
      try {
        final file = File(path);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage();
            },
          );
        } else {
          return _buildErrorImage();
        }
      } catch (e) {
        print('Error loading image: $e');
        return _buildErrorImage();
      }
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == widget.project.authorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.project.images.isNotEmpty) ...[
                      Container(
                        height: 300,
                        color: Colors.grey.shade100,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: widget.project.images.length,
                              onPageChanged: (index) {
                                if (mounted) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                }
                              },
                              itemBuilder: (context, index) {
                                return _buildImage(widget.project.images[index]);
                              },
                            ),

                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentImageIndex + 1}/${widget.project.images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            if (widget.project.images.length > 1) ...[
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_currentImageIndex > 0 && mounted) {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_currentImageIndex < widget.project.images.length - 1 && mounted) {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (widget.project.images.length > 1)
                        Container(
                          height: 70,
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.project.images.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _currentImageIndex == index
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    image: widget.project.images[index].startsWith('http')
                                        ? DecorationImage(
                                            image: NetworkImage(widget.project.images[index]),
                                            fit: BoxFit.cover,
                                          )
                                        : (File(widget.project.images[index]).existsSync()
                                            ? DecorationImage(
                                                image: FileImage(File(widget.project.images[index])),
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                  ),
                                  child: _currentImageIndex == index
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),
                    ],

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: _authorData?['photoUrl'] != null
                                      ? (_authorData!['photoUrl'].toString().startsWith('http')
                                          ? NetworkImage(_authorData!['photoUrl'])
                                          : (File(_authorData!['photoUrl']).existsSync()
                                              ? FileImage(File(_authorData!['photoUrl']))
                                              : null))
                                      : null,
                                  child: _authorData?['photoUrl'] == null ||
                                          (_authorData?['photoUrl'] != null &&
                                              !File(_authorData!['photoUrl']).existsSync())
                                      ? const Icon(Icons.person, size: 25)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _authorData?['fullName'] ?? widget.project.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _authorData?['university'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (currentUser != null && !isOwner)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xff314F6A),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chat, color: Colors.white),
                                      onPressed: () {
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                otherUserId: widget.project.authorId,
                                                otherUserName: _authorData?['fullName'] ?? widget.project.authorName,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.project.category,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.project.description,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: widget.project.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Colors.grey.shade100,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          if (widget.project.githubUrl != null && widget.project.githubUrl!.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GitHub Repository',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _launchURL(widget.project.githubUrl!),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.code, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            widget.project.githubUrl!,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (widget.project.documentUrl.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.description,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Project Document',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Tap to view PDF',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Opening document...'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}