

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../cubits/project/project_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
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

  File? _coverPhoto;
  List<File> _additionalImages = [];
  File? _selectedDocument;
  String _documentName = '';
  bool _isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  // قائمة التصنيفات
  final List<String> _categories = [
    'E-Commerce',
    'Education',
    'Sport',
    'Tourism',
    'Disability',
    'Agriculture',
    'Medical',
    'Healthcare',
    'Finance',
    'Transportation',
    'Lifestyle',
    'Social',
    'Business',
    'Environment',
  ];

  Future<void> _pickCoverPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _coverPhoto = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking cover photo: $e', Colors.red);
    }
  }

  Future<void> _pickAdditionalImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _additionalImages.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e', Colors.red);
    }
  }

  void _removeAdditionalImage(int index) {
    setState(() {
      _additionalImages.removeAt(index);
    });
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedDocument = File(result.files.single.path!);
          _documentName = result.files.single.name;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking document: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_coverPhoto == null) {
      _showSnackBar('Please add a cover photo', Colors.red);
      return;
    }
    
    if (_selectedDocument == null) {
      _showSnackBar('Please upload your project document (PDF)', Colors.red);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please login first', Colors.red);
      return;
    }

    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final userData = userDoc.data();
    final authorName = userData?['fullName'] ?? user.displayName ?? 'User';

    setState(() => _isUploading = true);

    try {
      await context.read<ProjectCubit>().addProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: _tagsController.text.trim(),
        category: _categoryController.text,
        githubUrl: _githubController.text.trim(),
        coverPhoto: _coverPhoto!,
        projectDocument: _selectedDocument!,
        authorId: user.uid,
        authorName: authorName,
        additionalImages: _additionalImages.isEmpty ? null : _additionalImages,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('✅ Project uploaded successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Project'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDEE9F7), Colors.white, Color(0xff7E9FCA)],
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
                    Text('Uploading project files...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Photo Section
                      const Text('Cover Photo *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickCoverPhoto,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _coverPhoto != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(_coverPhoto!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 50, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('Tap to upload cover photo', style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Additional Images
                      const Text('Additional Images For UI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (_additionalImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _additionalImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(image: FileImage(_additionalImages[index]), fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeAdditionalImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickAdditionalImages,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Add Images'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      const Text('Project Title *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter project name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Please enter title' : null,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text('Description *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe your project',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Please enter description' : null,
                      ),
                      const SizedBox(height: 20),

                      // Tags
                      const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          hintText: 'Flutter, AI, Mobile (comma separated)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category
                      const Text('Category *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isEmpty ? null : _categoryController.text,
                        hint: const Text('Select category'),
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (value) => setState(() => _categoryController.text = value ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) => v == null ? 'Please select category' : null,
                      ),
                      const SizedBox(height: 20),

                      // GitHub URL
                      const Text('GitHub URL (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _githubController,
                        decoration: InputDecoration(
                          hintText: 'https://github.com/...',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Document
                      const Text('Project Document (PDF) *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDocument,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _selectedDocument != null ? Colors.green : Colors.grey.shade300),
                          ),
                          child: _selectedDocument != null
                              ? Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_documentName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                          const Text('Tap to change', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.check_circle, color: Colors.green),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('Tap to upload PDF', style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff155DFC),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Upload Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600 , color:Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    _githubController.dispose();
    super.dispose();
  }
}
