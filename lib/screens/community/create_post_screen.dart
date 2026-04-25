// lib/screens/community/create_post_screen.dart
//
// Change: Removed "Only Me" visibility option. Only Public and My Team remain.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/community/community_cubit.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  final CommunityCubit cubit;

  const CreatePostScreen({
    super.key,
    required this.cubit,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  // ✅ Default to public; "Only Me" removed
  PostVisibility _visibility = PostVisibility.public;
  bool _isPosting = false;
  File? _selectedImage;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _getUserId(BuildContext context) {
    final userModel = context.read<AuthCubit>().state.userModel;
    return userModel?.uid ?? '';
  }

  String _getUserName(BuildContext context) {
    final userModel = context.read<AuthCubit>().state.userModel;
    return userModel?.fullName ?? '';
  }

  String _getUserInitial(BuildContext context) {
    final name = _getUserName(context);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get _visibilityLabel {
    switch (_visibility) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.myTeam:
        return 'My Team';
      case PostVisibility.onlyMe:
        // Shouldn't be reachable but guard anyway
        return 'My Team';
    }
  }

  IconData get _visibilityIcon {
    switch (_visibility) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.myTeam:
      case PostVisibility.onlyMe:
        return Icons.group;
    }
  }

  void _openVisibilityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Who can see your post?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              // ✅ Only two options: Public and My Team
              _visibilityTile(
                PostVisibility.public,
                Icons.public,
                'Public',
                'Anyone on Community',
              ),
              _visibilityTile(
                PostVisibility.myTeam,
                Icons.group,
                'My Team',
                'Your Team on Community',
              ),
              // ✅ "Only Me" REMOVED
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visibilityTile(
      PostVisibility value, IconData icon, String title, String sub) {
    final isSelected = _visibility == value;
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF155DFC)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(sub),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF155DFC))
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: () {
        setState(() => _visibility = value);
        Navigator.pop(context);
      },
    );
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first!')),
      );
      return;
    }

    final userId = _getUserId(context);
    final userName = _getUserName(context);
    final userInitial = _getUserInitial(context);

    print('📝 [CREATE POST] userId: $userId');
    print('📝 [CREATE POST] userName: $userName');

    setState(() => _isPosting = true);

    try {
      await widget.cubit.createPost(
        content: content,
        hashtags: _extractHashtags(content),
        visibility: _visibility,
        userId: userId,
        userName: userName,
        userInitial: userInitial,
        attachmentName: _selectedImage?.path,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName(context);
    final userInitial = _getUserInitial(context);

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
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 50,
                          offset: Offset(0, 25),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPostHeader(),
                        _buildPostBody(userName, userInitial),
                        _buildPostFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Community',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Create post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildPostBody(String userName, String userInitial) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: CircleBorder(),
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    userName.isNotEmpty ? userName : 'User',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
              // Visibility picker
              GestureDetector(
                onTap: _openVisibilityPicker,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_visibilityIcon,
                          size: 14, color: const Color(0xFF155DFC)),
                      const SizedBox(width: 4),
                      Text(
                        _visibilityLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.84),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 6,
            minLines: 4,
            decoration: const InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(color: Color(0xFF697282), fontSize: 16),
              border: InputBorder.none,
            ),
          ),
          // Image picker UI
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedImage == null
                        ? Icons.add_photo_alternate
                        : Icons.check_circle,
                    color: _selectedImage == null ? Colors.grey : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Text(_selectedImage == null
                      ? 'Add image'
                      : 'Image selected'),
                  const Spacer(),
                  if (_selectedImage != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child:
                          const Icon(Icons.close, size: 18, color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          // ✅ Visibility hint — only shown for My Team (not "Only Me")
          if (_visibility == PostVisibility.myTeam) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.group, size: 14, color: Color(0xFF155DFC)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only your team members can see this post',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF155DFC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: _isPosting ? null : _submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            disabledBackgroundColor:
                const Color(0xFF2196F3).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: _isPosting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}