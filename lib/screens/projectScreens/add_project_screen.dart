// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import '../models/project_model.dart';
// import '../main.dart';
// import 'package:path_provider/path_provider.dart';

// class AddProjectScreen extends StatefulWidget {
//   const AddProjectScreen({super.key});

//   @override
//   State<AddProjectScreen> createState() => _AddProjectScreenState();
// }

// class _AddProjectScreenState extends State<AddProjectScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _tagsController = TextEditingController();
//   final _categoryController = TextEditingController();

//   // للصور المتعددة من الجهاز
//   List<File> _selectedImages = [];
//   File? _selectedDocument;
//   String _documentName = '';

//   final ImagePicker _imagePicker = ImagePicker();
//   bool _isUploading = false;

//   // الحصول على المستخدم الحالي
//   User? get currentUser => FirebaseAuth.instance.currentUser;

//   Future<void> _pickImages() async {
//     try {
//       final List<XFile>? images = await _imagePicker.pickMultiImage(
//         imageQuality: 70,
//         maxWidth: 1000,
//       );

//       if (images != null) {
//         setState(() {
//           _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
//     }
//   }

//   Future<void> _pickDocument() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx'],
//         allowMultiple: false,
//       );

//       if (result != null) {
//         File originalFile = File(result.files.single.path!);

//         // 🔥 هنا بنجيب مكان دائم
//         final directory = await getApplicationDocumentsDirectory();

//         final newPath =
//             '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

//         // 🔥 هنا بننسخ الملف
//         File savedFile = await originalFile.copy(newPath);

//         setState(() {
//           _selectedDocument = savedFile; // نخزن النسخة الجديدة
//           _documentName = result.files.single.name;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking document: $e')));
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//     });
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (currentUser == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('You must be logged in to upload a project'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       setState(() {
//         _isUploading = true;
//       });

//       try {
//         // تحويل مسارات الصور المحلية إلى قائمة
//         List<String> imagePaths = _selectedImages
//             .map((file) => file.path)
//             .toList();

//         // مسار المستند المحلي
//         String documentPath = _selectedDocument?.path ?? '';

//         // تحويل النصوص إلى Tags
//         List<String> tags = _tagsController.text
//             .split(',')
//             .map((tag) => tag.trim())
//             .where((tag) => tag.isNotEmpty)
//             .toList();

//         // إنشاء مشروع جديد بالمسارات المحلية
//         final newProject = Project(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           title: _titleController.text,
//           description: _descriptionController.text,
//           authorId: currentUser!.uid,
//           authorName: currentUser!.displayName ?? 'Unknown User',
//           authorEmail: currentUser!.email ?? '',
//           authorPhotoUrl: currentUser?.photoURL ?? '',
//           images: imagePaths, // هنا المسارات المحلية
//           tags: tags.isNotEmpty ? tags : ['General'],
//           category: _categoryController.text,
//           documentUrl: documentPath, // المسار المحلي للمستند
//           createdAt: DateTime.now(),
//         );

//         // إضافة المشروع إلى Provider
//         Provider.of<ProjectProvider>(
//           context,
//           listen: false,
//         ).addProject(newProject);

//         // العودة للصفحة السابقة
//         Navigator.pop(context);

//         // عرض رسالة نجاح
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Project uploaded successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error uploading project: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } finally {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Project'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
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
//         child: _isUploading
//             ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Uploading project...'),
//                   ],
//                 ),
//               )
//             : SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // معلومات المستخدم
//                       if (currentUser != null)
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey.shade200),
//                           ),
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundImage: currentUser!.photoURL != null
//                                     ? NetworkImage(currentUser!.photoURL!)
//                                     : null,
//                                 child: currentUser!.photoURL == null
//                                     ? const Icon(Icons.person)
//                                     : null,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       currentUser!.displayName ?? 'No Name',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                     Text(
//                                       currentUser!.email ?? '',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       const SizedBox(height: 24),

//                       // Multiple Images Upload
//                       const Text(
//                         'Project Images',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'First image will be the cover photo',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                       const SizedBox(height: 8),

//                       // Grid View للصور المختارة من الجهاز
//                       if (_selectedImages.isNotEmpty)
//                         Container(
//                           height: 100,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: _selectedImages.length,
//                             itemBuilder: (context, index) {
//                               return Stack(
//                                 children: [
//                                   Container(
//                                     width: 100,
//                                     height: 100,
//                                     margin: const EdgeInsets.only(right: 8),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                         color: index == 0
//                                             ? Colors.blue
//                                             : Colors.grey.shade300,
//                                         width: index == 0 ? 2 : 1,
//                                       ),
//                                       // هنا الأهم: استخدام FileImage للصور المحلية
//                                       image: DecorationImage(
//                                         image: FileImage(
//                                           _selectedImages[index],
//                                         ),
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     child: index == 0
//                                         ? Align(
//                                             alignment: Alignment.topLeft,
//                                             child: Container(
//                                               padding: const EdgeInsets.all(4),
//                                               decoration: const BoxDecoration(
//                                                 color: Colors.blue,
//                                                 borderRadius: BorderRadius.only(
//                                                   topLeft: Radius.circular(6),
//                                                   bottomRight: Radius.circular(
//                                                     6,
//                                                   ),
//                                                 ),
//                                               ),
//                                               child: const Text(
//                                                 'Cover',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 10,
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : null,
//                                   ),
//                                   Positioned(
//                                     top: 0,
//                                     right: 8,
//                                     child: GestureDetector(
//                                       onTap: () => _removeImage(index),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(4),
//                                         decoration: const BoxDecoration(
//                                           color: Colors.red,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.close,
//                                           size: 14,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 8),

//                       // زر إضافة صور
//                       ElevatedButton.icon(
//                         onPressed: _pickImages,
//                         icon: const Icon(Icons.image),
//                         label: const Text('Add Images'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey.shade200,
//                           foregroundColor: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Project Title
//                       const Text(
//                         'Project Title',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _titleController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter project name',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter project title';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       // Description
//                       const Text(
//                         'Description',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _descriptionController,
//                         maxLines: 4,
//                         decoration: InputDecoration(
//                           hintText: 'Describe your project',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter project description';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       // Tags
//                       const Text(
//                         'Tags',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _tagsController,
//                         decoration: InputDecoration(
//                           hintText: 'eg. AI, REACT, CSS (separate with commas)',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Category
//                       const Text(
//                         'Category',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         value: _categoryController.text.isNotEmpty
//                             ? _categoryController.text
//                             : null,
//                         hint: const Text('Select category'),
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'E-Commerce',
//                             child: Text('E-Commerce'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Education',
//                             child: Text('Education'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Sport',
//                             child: Text('Sport'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Tourism',
//                             child: Text('Tourism'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Disability',
//                             child: Text('Disability'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Agriculture',
//                             child: Text('Agriculture'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'medical',
//                             child: Text('Medical'),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             _categoryController.text = value ?? '';
//                           });
//                         },
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select a category';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       // Document Upload
//                       const Text(
//                         'Upload Document (PDF)',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       GestureDetector(
//                         onTap: _pickDocument,
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: _selectedDocument != null
//                                   ? Colors.green
//                                   : Colors.grey.shade300,
//                               width: _selectedDocument != null ? 2 : 1,
//                             ),
//                           ),
//                           child: _selectedDocument != null
//                               ? Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.description,
//                                       color: Colors.green,
//                                       size: 30,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             _documentName,
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           Text(
//                                             'Tap to change',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Column(
//                                   children: [
//                                     Icon(
//                                       Icons.cloud_upload,
//                                       size: 40,
//                                       color: Colors.grey.shade400,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Tap to upload document',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                     Text(
//                                       'PDF, Docx up to 10MB',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey.shade500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 32),

//                       // Submit Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton(
//                           onPressed: _submitForm,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff155DFC),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Upload Project',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _tagsController.dispose();
//     _categoryController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import '../models/project_model.dart';
// import '../main.dart';
// import 'package:path_provider/path_provider.dart';

// class AddProjectScreen extends StatefulWidget {
//   const AddProjectScreen({super.key});

//   @override
//   State<AddProjectScreen> createState() => _AddProjectScreenState();
// }

// class _AddProjectScreenState extends State<AddProjectScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _tagsController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _githubController = TextEditingController();

//   // صور المشروع (أول صورة هي الكفر)
//   List<File> _projectImages = [];
//   File? _selectedDocument;
//   String _documentName = '';

//   final ImagePicker _imagePicker = ImagePicker();
//   bool _isUploading = false;

//   // الحصول على المستخدم الحالي
//   User? get currentUser => FirebaseAuth.instance.currentUser;

//   // دالة لاختيار صورة الكفر (صورة واحدة)
//   Future<void> _pickCoverImage() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//         maxWidth: 1000,
//       );

//       if (image != null) {
//         setState(() {
//           // إذا كانت القائمة فارغة، نضيف الصورة كأول عنصر (الكفر)
//           // إذا كان فيها عناصر، نستبدل أول عنصر بالصورة الجديدة
//           if (_projectImages.isEmpty) {
//             _projectImages.add(File(image.path));
//           } else {
//             _projectImages[0] = File(image.path);
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking cover image: $e')));
//     }
//   }

//   // دالة لاختيار صور إضافية للمشروع
//   Future<void> _pickProjectImages() async {
//     try {
//       final List<XFile>? images = await _imagePicker.pickMultiImage(
//         imageQuality: 70,
//         maxWidth: 1000,
//       );

//       if (images != null) {
//         setState(() {
//           _projectImages.addAll(images.map((xfile) => File(xfile.path)));
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
//     }
//   }

//   Future<void> _pickDocument() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx'],
//         allowMultiple: false,
//       );

//       if (result != null) {
//         File originalFile = File(result.files.single.path!);
//         final directory = await getApplicationDocumentsDirectory();
//         final newPath =
//             '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
//         File savedFile = await originalFile.copy(newPath);

//         setState(() {
//           _selectedDocument = savedFile;
//           _documentName = result.files.single.name;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error picking document: $e')));
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _projectImages.removeAt(index);
//     });
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (currentUser == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('You must be logged in to upload a project'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // التحقق من وجود صورة كفر
//       if (_projectImages.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please add a cover image for your project'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       setState(() {
//         _isUploading = true;
//       });

//       try {
//         // تحويل مسارات الصور المحلية إلى قائمة
//         List<String> imagePaths = _projectImages
//             .map((file) => file.path)
//             .toList();

//         // مسار المستند المحلي
//         String documentPath = _selectedDocument?.path ?? '';

//         // تحويل النصوص إلى Tags
//         List<String> tags = _tagsController.text
//             .split(',')
//             .map((tag) => tag.trim())
//             .where((tag) => tag.isNotEmpty)
//             .toList();

//         // إنشاء مشروع جديد بالمسارات المحلية - نستخدم فقط authorId و authorName

//         //然后在 _submitForm 方法中، أضف githubUrl إلى الـ Project
//         final newProject = Project(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           title: _titleController.text,
//           description: _descriptionController.text,
//           authorId: currentUser!.uid,
//           authorName: currentUser!.displayName ?? 'Unknown User',
//           images: imagePaths,
//           tags: tags.isNotEmpty ? tags : ['General'],
//           category: _categoryController.text,
//           documentUrl: documentPath,
//           githubUrl: _githubController.text, // إضافة GitHub URL
//           createdAt: DateTime.now(),
//         );

//         // إضافة المشروع إلى Provider
//         Provider.of<ProjectProvider>(
//           context,
//           listen: false,
//         ).addProject(newProject);

//         // العودة للصفحة السابقة
//         Navigator.pop(context);

//         // عرض رسالة نجاح
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Project uploaded successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error uploading project: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } finally {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Project'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
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
//         child: _isUploading
//             ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Uploading project...'),
//                   ],
//                 ),
//               )
//             : SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // معلومات المستخدم
//                       // if (currentUser != null)
//                       //   Container(
//                       //     padding: const EdgeInsets.all(16),
//                       //     decoration: BoxDecoration(
//                       //       color: Colors.white,
//                       //       borderRadius: BorderRadius.circular(12),
//                       //       border: Border.all(color: Colors.grey.shade200),
//                       //     ),
//                       //     child: Row(
//                       //       children: [
//                       //         CircleAvatar(
//                       //           backgroundImage: currentUser!.photoURL != null
//                       //               ? NetworkImage(currentUser!.photoURL!)
//                       //               : null,
//                       //           child: currentUser!.photoURL == null
//                       //               ? const Icon(Icons.person)
//                       //               : null,
//                       //         ),
//                       //         const SizedBox(width: 12),
//                       //         Expanded(
//                       //           child: Column(
//                       //             crossAxisAlignment: CrossAxisAlignment.start,
//                       //             children: [
//                       //               Text(
//                       //                 currentUser!.displayName ?? 'No Name',
//                       //                 style: const TextStyle(
//                       //                   fontWeight: FontWeight.bold,
//                       //                   fontSize: 16,
//                       //                 ),
//                       //               ),
//                       //               Text(
//                       //                 currentUser!.email ?? '',
//                       //                 style: TextStyle(
//                       //                   fontSize: 14,
//                       //                   color: Colors.grey.shade600,
//                       //                 ),
//                       //               ),
//                       //             ],
//                       //           ),
//                       //         ),
//                       //       ],
//                       //     ),
//                       //   ),
//                       const SizedBox(height: 24),

//                       // ===== Cover Photo Section (مثل الصورة المرفقة) =====
//                       const Text(
//                         'Cover Photo',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'First image will be the cover photo',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // حاوية صورة الكفر
//                       GestureDetector(
//                         onTap: _pickCoverImage,
//                         child: Container(
//                           width: double.infinity,
//                           height: 180,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: _projectImages.isNotEmpty
//                                   ? Colors.blue
//                                   : Colors.grey.shade300,
//                               width: 2,
//                             ),
//                             image: _projectImages.isNotEmpty
//                                 ? DecorationImage(
//                                     image: FileImage(_projectImages.first),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : null,
//                           ),
//                           child: _projectImages.isEmpty
//                               ? Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.cloud_upload,
//                                       size: 50,
//                                       color: Colors.grey.shade400,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Tap to upload cover image',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                     Text(
//                                       'PNG, JPG up to 10MB',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey.shade500,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Stack(
//                                   children: [
//                                     // النص "Cover" يظهر على الصورة
//                                     Positioned(
//                                       top: 12,
//                                       left: 12,
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 6,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.blue.withOpacity(0.8),
//                                           borderRadius: BorderRadius.circular(
//                                             20,
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           'Cover',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     // زر تغيير الصورة
//                                     Positioned(
//                                       top: 12,
//                                       right: 12,
//                                       child: GestureDetector(
//                                         onTap: _pickCoverImage,
//                                         child: Container(
//                                           padding: const EdgeInsets.all(8),
//                                           decoration: const BoxDecoration(
//                                             color: Colors.white,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(
//                                             Icons.edit,
//                                             size: 20,
//                                             color: Colors.blue,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // ===== Project Images Section (صور إضافية) =====
//                       const Text(
//                         'Project Images',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Add more images of your project ',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Grid View للصور الإضافية (بعد الكفر)
//                       if (_projectImages.length > 1)
//                         Container(
//                           height: 100,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount:
//                                 _projectImages.length - 1, // نبدأ من index 1
//                             itemBuilder: (context, index) {
//                               // نضيف 1 لأننا بدأنا من أول صورة بعد الكفر
//                               int actualIndex = index + 1;
//                               return Stack(
//                                 children: [
//                                   Container(
//                                     width: 100,
//                                     height: 100,
//                                     margin: const EdgeInsets.only(right: 8),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                         color: Colors.grey.shade300,
//                                       ),
//                                       image: DecorationImage(
//                                         image: FileImage(
//                                           _projectImages[actualIndex],
//                                         ),
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 0,
//                                     right: 8,
//                                     child: GestureDetector(
//                                       onTap: () => _removeImage(actualIndex),
//                                       child: Container(
//                                         padding: const EdgeInsets.all(4),
//                                         decoration: const BoxDecoration(
//                                           color: Colors.red,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.close,
//                                           size: 14,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ),
//                       const SizedBox(height: 8),

//                       // زر إضافة صور إضافية
//                       // if (_projectImages.isNotEmpty)
//                       ElevatedButton.icon(
//                         onPressed: _pickProjectImages,
//                         icon: const Icon(Icons.add_photo_alternate_outlined),
//                         label: const Text('Add More Images'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey.shade200,
//                           foregroundColor: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Project Title
//                       const Text(
//                         'Project Title',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _titleController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter project name',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter project title';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       // Description
//                       const Text(
//                         'Description',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _descriptionController,
//                         maxLines: 4,
//                         decoration: InputDecoration(
//                           hintText: 'Describe your project',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter project description';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       // Tags
//                       const Text(
//                         'Tags',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _tagsController,
//                         decoration: InputDecoration(
//                           hintText: 'eg. AI, REACT, CSS',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Category
//                       const Text(
//                         'Category',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         value: _categoryController.text.isNotEmpty
//                             ? _categoryController.text
//                             : null,
//                         hint: const Text('Select category'),
//                         items: const [
//                           DropdownMenuItem(
//                             value: 'E-Commerce',
//                             child: Text('E-Commerce'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Education',
//                             child: Text('Education'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Sport',
//                             child: Text('Sport'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Tourism',
//                             child: Text('Tourism'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Disability',
//                             child: Text('Disability'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'Agriculture',
//                             child: Text('Agriculture'),
//                           ),
//                           DropdownMenuItem(
//                             value: 'medical',
//                             child: Text('Medical'),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             _categoryController.text = value ?? '';
//                           });
//                         },
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select a category';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       const Text(
//                         'GitHub Repository',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _githubController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter GitHub URL',
//                           prefixIcon: const Icon(Icons.link),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter GitHub URL';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),

//                       // Document Upload
//                       const Text(
//                         'Upload Document (PDF)',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       GestureDetector(
//                         onTap: _pickDocument,
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: _selectedDocument != null
//                                   ? Colors.green
//                                   : Colors.grey.shade300,
//                               width: _selectedDocument != null ? 2 : 1,
//                             ),
//                           ),
//                           child: _selectedDocument != null
//                               ? Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.description,
//                                       color: Colors.green,
//                                       size: 30,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             _documentName,
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           Text(
//                                             'Tap to change',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Column(
//                                   children: [
//                                     Icon(
//                                       Icons.cloud_upload,
//                                       size: 40,
//                                       color: Colors.grey.shade400,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Tap to upload document',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                     Text(
//                                       'PDF, Docx up to 10MB',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey.shade500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 32),

//                       // Submit Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton(
//                           onPressed: _submitForm,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff155DFC),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Upload Project',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _tagsController.dispose();
//     _categoryController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../cubits/project/project_cubit.dart';
// import '../../models/project_model.dart';

// class AddProjectScreen extends StatefulWidget {
//   const AddProjectScreen({super.key});

//   @override
//   State<AddProjectScreen> createState() => _AddProjectScreenState();
// }

// class _AddProjectScreenState extends State<AddProjectScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _tagsController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _githubController = TextEditingController();

//   List<File> _projectImages = [];
//   File? _selectedDocument;
//   String _documentName = '';

//   final ImagePicker _imagePicker = ImagePicker();
//   bool _isUploading = false;

//   User? get currentUser => FirebaseAuth.instance.currentUser;

//   // دالة لجلب اسم المستخدم من Firestore
//   Future<String> _getUserName(String uid) async {
//     try {
//       var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       if (doc.exists) {
//         return doc.data()?['fullName'] ?? 'Unknown User';
//       }
//     } catch (e) {
//       print('Error fetching user name: $e');
//     }
//     return currentUser?.displayName ?? 'Unknown User';
//   }

//   // باقي الدوال كما هي (_pickCoverImage, _pickProjectImages, etc)
//   Future<void> _pickCoverImage() async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 70,
//         maxWidth: 1000,
//       );

//       if (image != null) {
//         setState(() {
//           if (_projectImages.isEmpty) {
//             _projectImages.add(File(image.path));
//           } else {
//             _projectImages[0] = File(image.path);
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking cover image: $e')),
//       );
//     }
//   }

//   Future<void> _pickProjectImages() async {
//     try {
//       final List<XFile>? images = await _imagePicker.pickMultiImage(
//         imageQuality: 70,
//         maxWidth: 1000,
//       );

//       if (images != null) {
//         setState(() {
//           _projectImages.addAll(images.map((xfile) => File(xfile.path)));
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking images: $e')),
//       );
//     }
//   }

//   Future<void> _pickDocument() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx'],
//         allowMultiple: false,
//       );

//       if (result != null) {
//         File originalFile = File(result.files.single.path!);
//         final directory = await getApplicationDocumentsDirectory();
//         final newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
//         File savedFile = await originalFile.copy(newPath);

//         setState(() {
//           _selectedDocument = savedFile;
//           _documentName = result.files.single.name;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking document: $e')),
//       );
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _projectImages.removeAt(index);
//     });
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (currentUser == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('You must be logged in to upload a project'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       if (_projectImages.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please add a cover image for your project'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       setState(() {
//         _isUploading = true;
//       });

//       try {
//         final projectId = DateTime.now().millisecondsSinceEpoch.toString();

//         List<String> imagePaths = _projectImages.map((file) => file.path).toList();
//         String documentPath = _selectedDocument?.path ?? '';

//         List<String> tags = _tagsController.text
//             .split(',')
//             .map((tag) => tag.trim())
//             .where((tag) => tag.isNotEmpty)
//             .toList();

//         // جلب اسم المستخدم
//         final authorName = await _getUserName(currentUser!.uid);

//         final newProject = Project(
//           id: projectId,
//           title: _titleController.text,
//           description: _descriptionController.text,
//           authorId: currentUser!.uid,
//           authorName: authorName,
//           images: imagePaths,
//           tags: tags.isNotEmpty ? tags : ['General'],
//           category: _categoryController.text,
//           documentUrl: documentPath,
//           githubUrl: _githubController.text.isNotEmpty ? _githubController.text : null,
//           createdAt: DateTime.now(),
//         );

//         await context.read<ProjectCubit>().addProject(newProject);

//         if (mounted) {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('✅ Project uploaded successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error uploading project: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isUploading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Project'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: BlocListener<ProjectCubit, ProjectState>(
//         listener: (context, state) {
//           if (state.status == ProjectStatus.error && state.errorMessage != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.errorMessage!),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 222, 233, 247),
//                 Colors.white,
//                 Color(0xff7E9FCA),
//               ],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: _isUploading
//               ? const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 16),
//                       Text('Uploading project...'),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(24),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // معلومات المستخدم
//                         if (currentUser != null)
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundImage: currentUser!.photoURL != null
//                                       ? NetworkImage(currentUser!.photoURL!)
//                                       : null,
//                                   child: currentUser!.photoURL == null
//                                       ? const Icon(Icons.person)
//                                       : null,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         currentUser!.displayName ?? 'No Name',
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       Text(
//                                         currentUser!.email ?? '',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         const SizedBox(height: 24),

//                         // Cover Photo
//                         const Text(
//                           'Cover Photo',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'First image will be the cover photo',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         GestureDetector(
//                           onTap: _pickCoverImage,
//                           child: Container(
//                             width: double.infinity,
//                             height: 180,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: _projectImages.isNotEmpty
//                                     ? Colors.blue
//                                     : Colors.grey.shade300,
//                                 width: 2,
//                               ),
//                               image: _projectImages.isNotEmpty
//                                   ? DecorationImage(
//                                       image: FileImage(_projectImages.first),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : null,
//                             ),
//                             child: _projectImages.isEmpty
//                                 ? Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.cloud_upload,
//                                         size: 50,
//                                         color: Colors.grey.shade400,
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Tap to upload cover image',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                       Text(
//                                         'PNG, JPG up to 10MB',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey.shade500,
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : Stack(
//                                     children: [
//                                       Positioned(
//                                         top: 12,
//                                         left: 12,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 6,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Colors.blue.withOpacity(0.8),
//                                             borderRadius: BorderRadius.circular(20),
//                                           ),
//                                           child: const Text(
//                                             'Cover',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         top: 12,
//                                         right: 12,
//                                         child: GestureDetector(
//                                           onTap: _pickCoverImage,
//                                           child: Container(
//                                             padding: const EdgeInsets.all(8),
//                                             decoration: const BoxDecoration(
//                                               color: Colors.white,
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: const Icon(
//                                               Icons.edit,
//                                               size: 20,
//                                               color: Colors.blue,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Project Images
//                         const Text(
//                           'Project Images',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Add more images of your project (optional)',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         if (_projectImages.length > 1)
//                           Container(
//                             height: 100,
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: _projectImages.length - 1,
//                               itemBuilder: (context, index) {
//                                 int actualIndex = index + 1;
//                                 return Stack(
//                                   children: [
//                                     Container(
//                                       width: 100,
//                                       height: 100,
//                                       margin: const EdgeInsets.only(right: 8),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(8),
//                                         border: Border.all(color: Colors.grey.shade300),
//                                         image: DecorationImage(
//                                           image: FileImage(_projectImages[actualIndex]),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 0,
//                                       right: 8,
//                                       child: GestureDetector(
//                                         onTap: () => _removeImage(actualIndex),
//                                         child: Container(
//                                           padding: const EdgeInsets.all(4),
//                                           decoration: const BoxDecoration(
//                                             color: Colors.red,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(
//                                             Icons.close,
//                                             size: 14,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                         const SizedBox(height: 8),

//                         if (_projectImages.isNotEmpty)
//                           ElevatedButton.icon(
//                             onPressed: _pickProjectImages,
//                             icon: const Icon(Icons.add_photo_alternate_outlined),
//                             label: const Text('Add More Images'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey.shade200,
//                               foregroundColor: Colors.black,
//                             ),
//                           ),
//                         const SizedBox(height: 24),

//                         // Project Title
//                         const Text(
//                           'Project Title',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _titleController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter project name',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter project title';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),

//                         // Description
//                         const Text(
//                           'Description',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _descriptionController,
//                           maxLines: 4,
//                           decoration: InputDecoration(
//                             hintText: 'Describe your project',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter project description';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),

//                         // Tags
//                         const Text(
//                           'Tags',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _tagsController,
//                           decoration: InputDecoration(
//                             hintText: 'eg. AI, REACT, CSS',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Category
//                         const Text(
//                           'Category',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         DropdownButtonFormField<String>(
//                           value: _categoryController.text.isNotEmpty
//                               ? _categoryController.text
//                               : null,
//                           hint: const Text('Select category'),
//                           items: const [
//                             DropdownMenuItem(value: 'E-Commerce', child: Text('E-Commerce')),
//                             DropdownMenuItem(value: 'Education', child: Text('Education')),
//                             DropdownMenuItem(value: 'Sport', child: Text('Sport')),
//                             DropdownMenuItem(value: 'Tourism', child: Text('Tourism')),
//                             DropdownMenuItem(value: 'Disability', child: Text('Disability')),
//                             DropdownMenuItem(value: 'Agriculture', child: Text('Agriculture')),
//                             DropdownMenuItem(value: 'medical', child: Text('Medical')),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               _categoryController.text = value ?? '';
//                             });
//                           },
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please select a category';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),

//                         // GitHub
//                         const Text(
//                           'GitHub Repository',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _githubController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter GitHub URL',
//                             prefixIcon: const Icon(Icons.link),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Document
//                         const Text(
//                           'Upload Document (PDF)',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         GestureDetector(
//                           onTap: _pickDocument,
//                           child: Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: _selectedDocument != null
//                                     ? Colors.green
//                                     : Colors.grey.shade300,
//                                 width: _selectedDocument != null ? 2 : 1,
//                               ),
//                             ),
//                             child: _selectedDocument != null
//                                 ? Row(
//                                     children: [
//                                       const Icon(Icons.description, color: Colors.green, size: 30),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               _documentName,
//                                               style: const TextStyle(fontWeight: FontWeight.w500),
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             Text(
//                                               'Tap to change',
//                                               style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : Column(
//                                     children: [
//                                       Icon(Icons.cloud_upload, size: 40, color: Colors.grey.shade400),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Tap to upload document',
//                                         style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                                       ),
//                                       Text(
//                                         'PDF, Docx up to 10MB',
//                                         style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),

//                         // Submit Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 56,
//                           child: ElevatedButton(
//                             onPressed: _submitForm,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xff155DFC),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text(
//                               'Upload Project',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _tagsController.dispose();
//     _categoryController.dispose();
//     _githubController.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../../cubits/project/project_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../models/project_model.dart';
import '../../models/user_model.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _githubController = TextEditingController();

  List<File> _projectImages = [];
  File? _selectedDocument;
  String _documentName = '';

  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (image != null) {
        setState(() {
          if (_projectImages.isEmpty) {
            _projectImages.add(File(image.path));
          } else {
            _projectImages[0] = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking cover image: $e')));
    }
  }

  Future<void> _pickProjectImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (images != null) {
        setState(() {
          _projectImages.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null) {
        File originalFile = File(result.files.single.path!);
        final directory = await getApplicationDocumentsDirectory();
        final newPath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        File savedFile = await originalFile.copy(newPath);

        setState(() {
          _selectedDocument = savedFile;
          _documentName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking document: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _projectImages.removeAt(index);
    });
  }

  Future<void> _submitForm(UserModel userModel) async {
    if (_formKey.currentState!.validate()) {
      if (_projectImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add a cover image for your project'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        final projectId = DateTime.now().millisecondsSinceEpoch.toString();

        List<String> imagePaths = _projectImages
            .map((file) => file.path)
            .toList();
        String documentPath = _selectedDocument?.path ?? '';

        List<String> tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        final newProject = Project(
          id: projectId,
          title: _titleController.text,
          description: _descriptionController.text,
          authorId: userModel.uid,
          authorName: userModel.fullName,
          images: imagePaths,
          tags: tags.isNotEmpty ? tags : ['General'],
          category: _categoryController.text,
          documentUrl: documentPath,
          githubUrl: _githubController.text.isNotEmpty
              ? _githubController.text
              : null,
          createdAt: DateTime.now(),
        );

        await context.read<ProjectCubit>().addProject(newProject);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Project uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  Widget _buildUserImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Color(0xff314F6A),
        child: Text('U', style: TextStyle(color: Colors.white)),
      );
    }

    if (photoUrl.startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(photoUrl));
    }

    return CircleAvatar(
      backgroundImage: FileImage(File(photoUrl)),
      onBackgroundImageError: (_, __) => const Icon(Icons.person),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated ||
            authState.userModel == null) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      'Please login to upload a project',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final userModel = authState.userModel!;

        if (userModel.role != UserRole.student) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 80, color: Colors.red),
                    const SizedBox(height: 20),
                    const Text(
                      'Only students can upload projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You are registered as ${userModel.role.value}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload Project'),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
            child: _isUploading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Uploading project...'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                _buildUserImage(userModel.photoUrl),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userModel.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        userModel.email,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        '${userModel.university ?? ''} • ${userModel.faculty ?? ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Cover Photo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'First image will be the cover photo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),

                          GestureDetector(
                            onTap: _pickCoverImage,
                            child: Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _projectImages.isNotEmpty
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                image: _projectImages.isNotEmpty
                                    ? DecorationImage(
                                        image: FileImage(_projectImages.first),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _projectImages.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 50,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to upload cover image',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'PNG, JPG up to 10MB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        Positioned(
                                          top: 12,
                                          left: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'Cover',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: GestureDetector(
                                            onTap: _pickCoverImage,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Project Images',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add more images of your project (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (_projectImages.length > 1)
                            Container(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _projectImages.length - 1,
                                itemBuilder: (context, index) {
                                  int actualIndex = index + 1;
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(
                                              _projectImages[actualIndex],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _removeImage(actualIndex),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 8),

                          if (_projectImages.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: _pickProjectImages,
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                              ),
                              label: const Text('Add More Images'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          const SizedBox(height: 24),

                          const Text(
                            'Project Title',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Enter project name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter project title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe your project',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter project description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _tagsController,
                            decoration: InputDecoration(
                              hintText: 'eg. AI, REACT, CSS',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _categoryController.text.isNotEmpty
                                ? _categoryController.text
                                : null,
                            hint: const Text('Select category'),
                            items: const [
                              DropdownMenuItem(
                                value: 'E-Commerce',
                                child: Text('E-Commerce'),
                              ),
                              DropdownMenuItem(
                                value: 'Education',
                                child: Text('Education'),
                              ),
                              DropdownMenuItem(
                                value: 'Sport',
                                child: Text('Sport'),
                              ),
                              DropdownMenuItem(
                                value: 'Tourism',
                                child: Text('Tourism'),
                              ),
                              DropdownMenuItem(
                                value: 'Disability',
                                child: Text('Disability'),
                              ),
                              DropdownMenuItem(
                                value: 'Agriculture',
                                child: Text('Agriculture'),
                              ),
                              DropdownMenuItem(
                                value: 'medical',
                                child: Text('Medical'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _categoryController.text = value ?? '';
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'GitHub Repository',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _githubController,
                            decoration: InputDecoration(
                              hintText: 'Enter GitHub URL',
                              prefixIcon: const Icon(Icons.link),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Upload Document (PDF)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDocument,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedDocument != null
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  width: _selectedDocument != null ? 2 : 1,
                                ),
                              ),
                              child: _selectedDocument != null
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.description,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _documentName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Tap to change',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to upload document',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'PDF, Docx up to 10MB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _submitForm(userModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff155DFC),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Upload Project',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
