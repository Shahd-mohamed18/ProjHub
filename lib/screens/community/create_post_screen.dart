// lib/screens/community/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/cubits/community/community_cubit.dart';

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
  PostVisibility _visibility = PostVisibility.public;
  bool _isPosting = false;

  // TODO: جيب دول من AuthCubit/UserModel لما الـ backend يجهز
  static const String _currentUserId = 'current_user';
  static const String _currentUserName = 'Marwa Mohamed';
  static const String _currentUserInitial = 'M';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String get _visibilityLabel {
    switch (_visibility) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.myTeam:
        return 'My Team';
      case PostVisibility.onlyMe:
        return 'Only Me';
    }
  }

  IconData get _visibilityIcon {
    switch (_visibility) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.myTeam:
        return Icons.group;
      case PostVisibility.onlyMe:
        return Icons.lock;
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
              _visibilityTile(
                PostVisibility.onlyMe,
                Icons.lock,
                'Only Me',
                'Only Me',
              ),
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

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first!')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // ✅ بنمرر userId و userName عشان الـ repository يعرف مين بوست
      await widget.cubit.createPost(
        content: content,
        hashtags: _extractHashtags(content),
        visibility: _visibility,
        userId: _currentUserId,
        userName: _currentUserName,
        userInitial: _currentUserInitial,
      );

      if (mounted) {
        // ✅ نرجع بدون result - الـ state اتحدث في الـ cubit مباشرة
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                        _buildPostBody(),
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
          BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4)),
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

  Widget _buildPostBody() {
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
                        _currentUserInitial,
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentUserName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
              // ✅ Visibility Picker
              GestureDetector(
                onTap: _openVisibilityPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          // ✅ Visibility info banner
          if (_visibility != PostVisibility.public) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _visibility == PostVisibility.onlyMe
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _visibilityIcon,
                    size: 14,
                    color: _visibility == PostVisibility.onlyMe
                        ? Colors.orange
                        : const Color(0xFF155DFC),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _visibility == PostVisibility.onlyMe
                        ? 'Only you can see this post'
                        : 'Only your team members can see this post',
                    style: TextStyle(
                      fontSize: 12,
                      color: _visibility == PostVisibility.onlyMe
                          ? Colors.orange[700]
                          : const Color(0xFF155DFC),
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
            disabledBackgroundColor: const Color(0xFF2196F3).withOpacity(0.5),
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