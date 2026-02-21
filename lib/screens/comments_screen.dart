// lib/screens/comments_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/post_model.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    // TODO: استبدل بـ API call حقيقي
    // final comments = await CommentService.getComments(widget.post.id);
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    setState(() {
      _comments = CommentModel.mockComments;
      _isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    // TODO: استبدل بـ API call حقيقي
    // await CommentService.postComment(widget.post.id, text);
    await Future.delayed(const Duration(milliseconds: 300)); // simulate network

    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Me', // TODO: من بيانات اليوزر الحالي
      userInitial: 'M',
      timeAgo: 'Just now',
      content: text,
      likes: 0,
    );

    setState(() {
      _comments.add(newComment);
      widget.post.comments += 1;
      _isSending = false;
    });

    _commentController.clear();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOriginalPost(),
                    const SizedBox(height: 24),
                    Text(
                      'Comments(${widget.post.comments})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Comments List
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_comments.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No comments yet. Be the first!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _CommentCard(
                            comment: _comments[index],
                            onLike: () {
                              setState(() {
                                final c = _comments[index];
                                c.isLiked = !c.isLiked;
                                c.likes += c.isLiked ? 1 : -1;
                              });
                              // TODO: CommentService.likeComment(_comments[index].id)
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            _buildCommentInput(),
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
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 44,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.arrow_back_ios_new, size: 20),
                // 🔙 TODO: Replace with back arrow icon from assets
              ),
            ),
          ),
          const Positioned(
            left: 64,
            top: 44,
            child: Text(
              'Post Comment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalPost() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            widget.post.content,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF155DFC),
              shape: BoxShape.circle,
            ),
            child: _isSending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _sendComment,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    // 📤 TODO: Replace with send icon from assets
                  ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget منفصل للكومنت عشان أحسن performance
class _CommentCard extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onLike;

  const _CommentCard({
    required this.comment,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    comment.userInitial,
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
                    comment.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    comment.timeAgo,
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
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Icon(
                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: comment.isLiked ? Colors.red : null,
                  // ❤️ TODO: Replace with like icon from assets
                ),
              ),
              const SizedBox(width: 8),
              Text('${comment.likes}'),
              const SizedBox(width: 21),
              GestureDetector(
                onTap: () {
                  // TODO: Reply to comment
                },
                child: const Text(
                  'Reply',
                  style: TextStyle(
                    color: Color(0xFF155DFC),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}