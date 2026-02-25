// lib/widgets/community/post_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';

// ✅ PostCard لا يعدل على الـ Model مباشرة
// الـ Like callback يرجع للـ Screen/Cubit
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onCommentTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserRow(),
            const SizedBox(height: 12),
            Text(post.content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            _buildHashtags(),
            if (post.attachmentName != null) ...[
              const SizedBox(height: 8),
              _buildAttachment(),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow() {
    return Row(
      children: [
        _CommunityAvatar(initial: post.userInitial),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.userName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(post.timeAgo,
                style: const TextStyle(color: Color(0xFF6A7282), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildHashtags() {
    return Wrap(
      spacing: 8,
      children: post.hashtags
          .map((tag) => Text(tag,
              style: const TextStyle(color: Color(0xFF155DFC), fontSize: 12)))
          .toList(),
    );
  }

  Widget _buildAttachment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 16),
          const SizedBox(width: 8),
          Text(post.attachmentName!,
              style: const TextStyle(color: Color(0xFF4A5565), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          child: Row(
            children: [
              Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? Colors.red : const Color(0xFF6A7282),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('${post.likes} Likes',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5565))),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: onCommentTap,
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 18, color: Color(0xFF6A7282)),
              const SizedBox(width: 6),
              Text('${post.commentsCount} Comments',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF4A5565))),
            ],
          ),
        ),
      ],
    );
  }
}

// ✅ Reusable Avatar - بتستخدمه PostCard و CommentsScreen
class CommunityAvatar extends StatelessWidget {
  final String initial;
  const CommunityAvatar({super.key, required this.initial});

  @override
  Widget build(BuildContext context) {
    return _CommunityAvatar(initial: initial);
  }
}

class _CommunityAvatar extends StatelessWidget {
  final String initial;
  const _CommunityAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const ShapeDecoration(
        color: Color(0xFFDBEAFE),
        shape: CircleBorder(),
      ),
      child: Center(
        child: Text(initial,
            style: const TextStyle(color: Color(0xFF155DFC), fontSize: 14)),
      ),
    );
  }
}