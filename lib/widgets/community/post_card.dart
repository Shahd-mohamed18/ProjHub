// lib/widgets/community/post_card.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/CommnityModels/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onCommentTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      widget.post.isLiked = _isLiked;
      widget.post.likes = _likesCount;
    });
    // TODO: PostService.likePost(widget.post.id)
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 337,
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
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
            // User Info Row
            Row(
              children: [
                // 👤 TODO: Replace with user avatar from assets or network image
                Container(
                  width: 40,
                  height: 40,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: CircleBorder(),
                  ),
                  child: Center(
                    child: Text(
                      widget.post.userInitial,
                      style: const TextStyle(
                        color: Color(0xFF155DFC),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.post.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF6A7282),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Hashtags
            Wrap(
              spacing: 8,
              children: widget.post.hashtags.map((tag) {
                return Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFF155DFC),
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            // Attachment (if any)
            if (widget.post.attachment != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 35,
                padding: const EdgeInsets.only(left: 12),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF9FAFB),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    // 📎 TODO: Replace with attachment icon from assets
                    const Icon(Icons.attach_file, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      widget.post.attachment!,
                      style: const TextStyle(
                        color: Color(0xFF4A5565),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),

            // Likes & Comments
            Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : null,
                        size: 16,
                        // ❤️ TODO: Replace with like icon from assets
                      ),
                      const SizedBox(width: 8),
                      Text('$_likesCount Likes'),
                    ],
                  ),
                ),
                const SizedBox(width: 21),

                // Comment Button
                GestureDetector(
                  onTap: widget.onCommentTap,
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 16),
                      // 💬 TODO: Replace with comment icon from assets
                      const SizedBox(width: 8),
                      Text('${widget.post.comments} Comments'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}