// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:onboard/widgets/Profile/image_picker_widget.dart';
// import 'package:onboard/widgets/Profile/custom_form_field_widget.dart';

// class EditProfileScreen extends StatefulWidget {
//   final String currentName;
//   final String currentBio;
//   final String currentUniversity;
//   final String currentImage;

//   const EditProfileScreen({
//     super.key,
//     required this.currentName,
//     required this.currentBio,
//     required this.currentUniversity,
//     required this.currentImage,
//   });

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   late TextEditingController nameController;
//   late TextEditingController bioController;
//   late TextEditingController universityController;
//   late String selectedImagePath;

//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.currentName);
//     bioController = TextEditingController(text: widget.currentBio);
//     universityController = TextEditingController(text: widget.currentUniversity);
//     selectedImagePath = widget.currentImage;
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     bioController.dispose();
//     universityController.dispose();
//     super.dispose();
//   }

//   void _onImageSelected(XFile? image) {
//     if (image != null) {
//       setState(() {
//         selectedImagePath = image.path;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFEFF6FF),
//               Color(0xFFF4F4F4),
//               Color(0xFF7D9FCA),
//             ],
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildAppBar(context),
//               const SizedBox(height: 20),
//               _buildEditForm(),
//               const SizedBox(height: 40),
//               _buildActionButtons(context),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 4,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (Navigator.canPop(context)) {
//                 Navigator.pop(context);
//               }
//             },
//             child: const Icon(Icons.arrow_back_ios_new, size: 24),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'Edit Profile',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEditForm() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             ImagePickerWidget(
//               onImageSelected: _onImageSelected,
//               radius: 60,
//               cameraIconSize: 24,
//               backgroundColor: const Color(0xFFDBEAFE),
//               iconColor: const Color(0xFF1E3A8A),
//               initialImagePath: selectedImagePath,
//             ),
//             const SizedBox(height: 24),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Full Name',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             CustomFormFieldWidget(
//               textController: nameController,
//               text: 'Enter your full name',
//               icon: const Icon(Icons.person_outline, color: Color(0xFF1E3A8A)),
//               valuValidation: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your name';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Bio',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             CustomFormFieldWidget(
//               textController: bioController,
//               text: 'Enter your bio',
//               icon: const Icon(Icons.info_outline, color: Color(0xFF1E3A8A)),
//               valuValidation: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your bio';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'University',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             CustomFormFieldWidget(
//               textController: universityController,
//               text: 'Enter your university',
//               icon: const Icon(Icons.school_outlined, color: Color(0xFF1E3A8A)),
//               valuValidation: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your university';
//                 }
//                 return null;
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 if (Navigator.canPop(context)) {
//                   Navigator.pop(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[300],
//                 foregroundColor: Colors.black87,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   Navigator.pop(context, {
//                     'name': nameController.text.trim(),
//                     'bio': bioController.text.trim(),
//                     'university': universityController.text.trim(),
//                     'imagePath': selectedImagePath,
//                   });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1E3A8A),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Save',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/widgets/Profile/image_picker_widget.dart';
import 'package:onboard/widgets/Profile/custom_form_field_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String? currentUniversity;
  final String? currentPosition;
  final String? currentDepartment;
  final String currentImage;
  final UserRole role;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBio,
    this.currentUniversity,
    this.currentPosition,
    this.currentDepartment,
    required this.currentImage,
    required this.role,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController universityController;
  late TextEditingController positionController;
  late TextEditingController departmentController;
  late String selectedImagePath;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
    universityController = TextEditingController(text: widget.currentUniversity ?? '');
    positionController = TextEditingController(text: widget.currentPosition ?? '');
    departmentController = TextEditingController(text: widget.currentDepartment ?? '');
    selectedImagePath = widget.currentImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    universityController.dispose();
    positionController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  void _onImageSelected(XFile? image) {
    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();
    
    if (widget.role == UserRole.student) {
      await authCubit.updateUserProfile(
        fullName: nameController.text.trim(),
        bio: bioController.text.trim(),
        university: universityController.text.trim(),
        photoUrl: selectedImagePath != widget.currentImage ? selectedImagePath : null,
        context: context,
      );
    } else {
      await authCubit.updateUserProfile(
        fullName: nameController.text.trim(),
        bio: bioController.text.trim(),
        position: positionController.text.trim(),
        department: departmentController.text.trim(),
        photoUrl: selectedImagePath != widget.currentImage ? selectedImagePath : null,
        context: context,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isStudent = widget.role == UserRole.student;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFF4F4F4),
              Color(0xFF7D9FCA),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 20),
              _buildEditForm(isStudent),
              const SizedBox(height: 40),
              _buildActionButtons(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 24),
          ),
          const SizedBox(width: 8),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(bool isStudent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ImagePickerWidget(
              onImageSelected: _onImageSelected,
              radius: 60,
              cameraIconSize: 24,
              backgroundColor: const Color(0xFFDBEAFE),
              iconColor: const Color(0xFF1E3A8A),
              initialImagePath: selectedImagePath,
            ),
            const SizedBox(height: 24),
            
            _buildField(
              label: 'Full Name',
              controller: nameController,
              icon: Icons.person_outline,
            ),
            
            _buildField(
              label: 'Bio',
              controller: bioController,
              icon: Icons.info_outline,
              maxLines: 3,
            ),
            
            if (isStudent) ...[
              _buildField(
                label: 'University',
                controller: universityController,
                icon: Icons.school_outlined,
              ),
            ] else ...[
              _buildField(
                label: widget.role == UserRole.doctor ? 'Position' : 'Role',
                controller: positionController,
                icon: Icons.badge_outlined,
              ),
              _buildField(
                label: 'Department',
                controller: departmentController,
                icon: Icons.business_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomFormFieldWidget(
          textController: controller,
          text: 'Enter your $label',
          icon: Icon(icon, color: const Color(0xFF1E3A8A)),
          valuValidation: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
          // maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}