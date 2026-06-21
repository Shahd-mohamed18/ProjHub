// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io';
// import '../../cubits/project/project_cubit.dart';
// import '../../models/project_model.dart';
// import '../chatScreens/chat_screen.dart';

// class ProjectDetailsScreen extends StatefulWidget {
//   final Project project;

//   const ProjectDetailsScreen({super.key, required this.project});

//   @override
//   State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
// }

// class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
//   final PageController _pageController = PageController();
//   int _currentImageIndex = 0;
//   bool _isOwner = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkOwner();
//   }

//   void _checkOwner() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     _isOwner = currentUser?.uid == widget.project.authorId;
//   }

//   Future<void> _launchURL(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   void _openDocument() {
//     if (widget.project.documentUrl.isNotEmpty) {
//       context.read<ProjectCubit>().openProjectDocument(
//         widget.project.documentUrl,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No document available'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Widget _buildImage(String imageUrl) {
//     if (imageUrl.isEmpty) {
//       return Container(
//         color: Colors.grey.shade200,
//         child: const Icon(Icons.image_not_supported, size: 50),
//       );
//     }

//     return Image.network(
//       imageUrl,
//       fit: BoxFit.contain,
//       width: double.infinity,
//       height: double.infinity,
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return Center(
//           child: CircularProgressIndicator(
//             value: loadingProgress.expectedTotalBytes != null
//                 ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                 : null,
//           ),
//         );
//       },
//       errorBuilder: (_, __, ___) => Container(
//         color: Colors.grey.shade200,
//         child: const Icon(Icons.broken_image, size: 50),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.project.title),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//         actions: const [],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFDEE9F7), Colors.white, Color(0xff7E9FCA)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Image Gallery
//               if (widget.project.images.isNotEmpty) ...[
//                 SizedBox(
//                   height: 300,
//                   child: Stack(
//                     children: [
//                       PageView.builder(
//                         controller: _pageController,
//                         itemCount: widget.project.images.length,
//                         onPageChanged: (index) =>
//                             setState(() => _currentImageIndex = index),
//                         itemBuilder: (context, index) {
//                           return Container(
//                             child: Center(
//                               child: _buildImage(widget.project.images[index]),
//                             ),
//                           );
//                         },
//                       ),
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
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       if (widget.project.images.length > 1) ...[
//                         Positioned(
//                           left: 8,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: IconButton(
//                               icon: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_back_ios,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               onPressed: () => _pageController.previousPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               ),
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
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.arrow_forward_ios,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               onPressed: () => _pageController.nextPage(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Thumbnails
//                 if (widget.project.images.length > 1)
//                   Container(
//                     height: 80,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
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
//                             height: 70,
//                             margin: const EdgeInsets.symmetric(horizontal: 4),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: _currentImageIndex == index
//                                     ? Colors.blue
//                                     : Colors.grey.shade300,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(6),
//                               child: Image.network(
//                                 widget.project.images[index],
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 errorBuilder: (_, __, ___) => Container(
//                                   color: Colors.grey.shade200,
//                                   child: const Icon(
//                                     Icons.broken_image,
//                                     size: 30,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 const SizedBox(height: 16),
//               ],

//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Category Chip
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
//                         style: TextStyle(color: Colors.blue.shade700),
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     // Title
//                     Text(
//                       widget.project.title,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             blurRadius: 10,
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundImage:
//                                 widget.project.userImage != null &&
//                                     widget.project.userImage!.isNotEmpty
//                                 ? NetworkImage(widget.project.userImage!)
//                                 : null,
//                             child:
//                                 widget.project.userImage == null ||
//                                     widget.project.userImage!.isEmpty
//                                 ? const Icon(Icons.person, size: 25)
//                                 : null,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   widget.project.authorName,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (currentUser != null && !_isOwner)
//                             ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ChatScreen(
//                                       otherUserId: widget.project.authorId,
//                                       otherUserName: widget.project.authorName,
//                                       otherUserPhoto: widget.project.userImage,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               icon: const Icon(Icons.chat, size: 18),
//                               label: const Text('Chat'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF2196F3),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Description
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
//                     const SizedBox(height: 20),

//                     // Tags
//                     if (widget.project.tags.isNotEmpty) ...[
//                       const Text(
//                         'Tags',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         children: widget.project.tags
//                             .map((tag) => Chip(label: Text(tag)))
//                             .toList(),
//                       ),
//                       const SizedBox(height: 20),
//                     ],

//                     // GitHub Link
//                     if (widget.project.githubUrl != null &&
//                         widget.project.githubUrl!.isNotEmpty)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: InkWell(
//                           onTap: () => _launchURL(widget.project.githubUrl!),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.code, color: Colors.black),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   widget.project.githubUrl!,
//                                   style: const TextStyle(color: Colors.blue),
//                                 ),
//                               ),
//                               const Icon(Icons.open_in_new, size: 16),
//                             ],
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 20),

//                     // Document Button
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: InkWell(
//                         onTap: _openDocument,
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.picture_as_pdf,
//                               color: Colors.red,
//                               size: 30,
//                             ),
//                             const SizedBox(width: 12),
//                             const Expanded(
//                               child: Text(
//                                 'Project Document',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             const Icon(Icons.open_in_new, color: Colors.grey),
//                           ],
//                         ),
//                       ),
//                     ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../cubits/project/project_cubit.dart';
import '../../models/project_model.dart';
import '../chatScreens/chat_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _checkOwner();
  }

  void _checkOwner() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _isOwner = currentUser?.uid == widget.project.authorId;
  }

  Future<void> _launchURL(String url) async {
    try {
      if (url.isEmpty) {
        _showSnackBar('URL is empty', Colors.red);
        return;
      }

      String cleanUrl = url.trim();

      // Add https:// if missing
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);

      // Try multiple methods to open the URL
      bool launched = false;

      // Method 1: Try with external application
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // Method 2: If failed, try with in-app WebView or browser
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          print('Method 2 failed: $e');
        }
      }

      // Method 3: Try with web view
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } catch (e) {
          print('Method 3 failed: $e');
        }
      }

      if (!launched) {
        _showSnackBar(
          'Cannot open URL. Please copy and paste in browser.',
          Colors.orange,
        );
        // Show dialog with the URL to copy
        _showCopyUrlDialog(cleanUrl);
      }
    } catch (e) {
      _showSnackBar('Error opening URL: $e', Colors.red);
    }
  }

  void _showCopyUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to open the link automatically. You can copy the URL and open it in your browser:',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                url,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Copy URL to clipboard
              // You need to add clipboard package for this
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy URL'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openDocument() {
    if (widget.project.documentUrl.isNotEmpty) {
      context.read<ProjectCubit>().openProjectDocument(
        widget.project.documentUrl,
      );
    } else {
      _showSnackBar('No document available', Colors.red);
    }
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
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
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: const [],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDEE9F7), Colors.white, Color(0xff7E9FCA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Gallery
              if (widget.project.images.isNotEmpty) ...[
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.project.images.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          return Container(
                            child: Center(
                              child: _buildImage(widget.project.images[index]),
                            ),
                          );
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
                            style: const TextStyle(color: Colors.white),
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Thumbnails
                if (widget.project.images.length > 1)
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.project.images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentImageIndex == index
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                widget.project.images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
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
                    // Category Chip
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
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                widget.project.userImage != null &&
                                    widget.project.userImage!.isNotEmpty
                                ? NetworkImage(widget.project.userImage!)
                                : null,
                            child:
                                widget.project.userImage == null ||
                                    widget.project.userImage!.isEmpty
                                ? const Icon(Icons.person, size: 25)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.project.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (currentUser != null && !_isOwner)
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      otherUserId: widget.project.authorId,
                                      otherUserName: widget.project.authorName,
                                      otherUserPhoto: widget.project.userImage,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat, size: 18),
                              label: const Text('Chat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
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
                    const SizedBox(height: 20),

                    // Tags
                    if (widget.project.tags.isNotEmpty) ...[
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
                        children: widget.project.tags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // GitHub Link
                    if (widget.project.githubUrl != null &&
                        widget.project.githubUrl!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _launchURL(widget.project.githubUrl!),
                          child: Row(
                            children: [
                              const Icon(Icons.code, color: Colors.black),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.project.githubUrl!,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.open_in_new, size: 16),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Document Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: _openDocument,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Project Document',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.open_in_new, color: Colors.grey),
                          ],
                        ),
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
