// import 'package:flutter/material.dart';
// import 'package:onboard/models/project_model.dart';
// import 'package:onboard/screens/projectScreens/project_details_screen.dart';

// class ProjectCard extends StatelessWidget {
//   final Project project;

//   const ProjectCard({super.key, required this.project});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProjectDetailsScreen(project: project),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ✅ صورة المشروع المصغرة (Cover Image)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: project.images.isNotEmpty
//                     ? Image.network(
//                         project.images.first,
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           width: 80,
//                           height: 80,
//                           color: Colors.grey.shade200,
//                           child: const Icon(Icons.image, color: Colors.grey),
//                         ),
//                       )
//                     : Container(
//                         width: 80,
//                         height: 80,
//                         color: Colors.grey.shade200,
//                         child: const Icon(Icons.business_center, color: Colors.grey),
//                       ),
//               ),
//               const SizedBox(width: 12),

//               // ✅ تفاصيل المشروع
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // عنوان المشروع
//                     Text(
//                       project.title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),

//                     // وصف المشروع
//                     Text(
//                       project.description,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),

//                     // ✅ صورة المؤلف + اسمه (من الباك اند)
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 12,
//                           backgroundImage: project.userImage != null && project.userImage!.isNotEmpty
//                               ? NetworkImage(project.userImage!)
//                               : null,
//                           child: project.userImage == null || project.userImage!.isEmpty
//                               ? const Icon(Icons.person, size: 12)
//                               : null,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             project.authorName,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey.shade700,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
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
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';
import '../../screens/projectScreens/project_details_screen.dart';

class ProjectCard extends StatefulWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
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
      print('Error fetching author data in ProjectCard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage();
        },
      );
    } else {
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
        return _buildErrorImage();
      }
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 30, color: Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(
            'No image',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProjectDetailsScreen(project: widget.project),
            ),
          );
        }
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: widget.project.images.isNotEmpty
                      ? _buildImage(widget.project.coverImage)
                      : _buildErrorImage(),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: _authorData?['photoUrl'] != null
                              ? (_authorData!['photoUrl'].toString().startsWith(
                                      'http',
                                    )
                                    ? NetworkImage(_authorData!['photoUrl'])
                                    : (File(
                                            _authorData!['photoUrl'],
                                          ).existsSync()
                                          ? FileImage(
                                              File(_authorData!['photoUrl']),
                                            )
                                          : null))
                              : null,
                          child:
                              _authorData?['photoUrl'] == null ||
                                  (_authorData?['photoUrl'] != null &&
                                      !File(
                                        _authorData!['photoUrl'],
                                      ).existsSync())
                              ? const Icon(Icons.person, size: 10)
                              : null,
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            _isLoading
                                ? 'Loading...'
                                : (_authorData?['fullName'] ??
                                      widget.project.authorName),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (_authorData?['track'] != null && !_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _authorData!['track'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 8),

                    Text(
                      widget.project.description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 6,
                      children: widget.project.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (widget.project.projectImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.collections,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.project.projectImages.length} more images',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
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
}
