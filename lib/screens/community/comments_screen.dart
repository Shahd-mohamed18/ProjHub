// lib/screens/community/comments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_comments_cubit.dart';
import 'package:onboard/cubits/community/community_cubit.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/community_repository.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // اسم اللي هيكون مذكور في الـ reply (لو في reply)
  String? _replyingToName;

  // TODO: جيب من AuthCubit
  static const String _currentUserId = 'current_user';
  static const String _currentUserName = 'Marwa';

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(String userName) {
    setState(() => _replyingToName = userName);
    _commentController.text = '@$userName ';
    _focusNode.requestFocus();
    // نخلي الـ cursor في الآخر
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  void _cancelReply() {
    setState(() => _replyingToName = null);
    _commentController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityCommentsCubit(MockCommunityRepository())
        ..loadComments(widget.post.id),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              _buildPostCard(),
              Expanded(
                child: BlocBuilder<CommunityCommentsCubit, CommentsPostState>(
                  builder: (context, state) {
                    if (state is CommentsPostLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CommentsPostError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            Text(state.message),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<CommunityCommentsCubit>()
                                  .loadComments(widget.post.id),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is CommentsPostLoaded) {
                      if (state.comments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet\nBe the first!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final comment = state.comments[index];
                          return _CommentCard(
                            comment: comment,
                            onLike: () => context
                                .read<CommunityCommentsCubit>()
                                .toggleCommentLike(
                                    widget.post.id, comment.id),
                            onReply: () => _startReply(comment.userName),
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
              // ✅ Banner الـ Reply
              if (_replyingToName != null) _buildReplyBanner(),
              _buildCommentInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 96,
      padding: const EdgeInsets.only(top: 48, left: 24, bottom: 16, right: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Post Comment', style: TextStyle(fontSize: 24)),
          const Spacer(),
          Icon(Icons.notifications_none_outlined,
              color: Colors.grey[700], size: 24),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                width: 40, height: 40,
                decoration: const ShapeDecoration(
                    color: Color(0xFFDBEAFE), shape: CircleBorder()),
                child: Center(
                  child: Text(widget.post.userInitial,
                      style: const TextStyle(
                          color: Color(0xFF155DFC), fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(widget.post.timeAgo,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6A7282))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.post.content, style: const TextStyle(fontSize: 14)),
          if (widget.post.hashtags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: widget.post.hashtags
                  .map((tag) => Text(tag,
                      style: const TextStyle(
                          color: Color(0xFF155DFC), fontSize: 12)))
                  .toList(),
            ),
          ],
          if (widget.post.attachmentName != null) ...[
            const SizedBox(height: 8),
            Container(
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
                  Text(widget.post.attachmentName!,
                      style: const TextStyle(
                          color: Color(0xFF4A5565), fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: widget.post.isLiked ? Colors.red : const Color(0xFF6A7282),
              ),
              const SizedBox(width: 6),
              Text('${widget.post.likes} Likes',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF4A5565))),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline,
                  size: 16, color: Color(0xFF6A7282)),
              const SizedBox(width: 6),
              BlocBuilder<CommunityCommentsCubit, CommentsPostState>(
                builder: (context, state) {
                  final count = state is CommentsPostLoaded
                      ? state.totalCount
                      : widget.post.commentsCount;
                  return Text('$count Comments',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF4A5565)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Banner بيظهر لما اليوزر يضغط Reply
  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16, color: Color(0xFF155DFC)),
          const SizedBox(width: 8),
          Text(
            'Replying to @$_replyingToName',
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF155DFC),
                fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _cancelReply,
            child: const Icon(Icons.close,
                size: 18, color: Color(0xFF6A7282)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return BlocBuilder<CommunityCommentsCubit, CommentsPostState>(
      builder: (context, state) {
        final isSending = state is CommentsPostLoaded && state.isSending;

        return Container(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _replyingToName != null
                        ? 'Reply to @$_replyingToName...'
                        : 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendComment(context),
                ),
              ),
              const SizedBox(width: 12),
              isSending
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : GestureDetector(
                      onTap: () => _sendComment(context),
                      child: Container(
                        width: 42, height: 42,
                        decoration: const ShapeDecoration(
                            color: Color(0xFF155DFC), shape: CircleBorder()),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 18),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _sendComment(BuildContext context) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    context.read<CommunityCommentsCubit>().addComment(
          postId: widget.post.id,
          content: text,
          userId: _currentUserId,
          userName: _currentUserName,
        );

    _commentController.clear();
    _focusNode.unfocus();
    setState(() => _replyingToName = null);

    try {
      context.read<CommunityCubit>().incrementCommentCount(widget.post.id);
    } catch (_) {}
  }
}

// ──────────────────────────────────────────
// Comment Card
// ──────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  final CommunityCommentModel comment;
  final VoidCallback onLike;
  final VoidCallback onReply; // ✅ شغال دلوقتي

  const _CommentCard({
    required this.comment,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFDBEAFE),
                child: Text(comment.userInitial,
                    style: const TextStyle(
                        color: Color(0xFF155DFC), fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(comment.timeAgo,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: comment.isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${comment.likes}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // ✅ Reply - شغال فعلاً
              GestureDetector(
                onTap: onReply,
                child: const Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: Color(0xFF155DFC)),
                    SizedBox(width: 4),
                    Text('Reply',
                        style: TextStyle(
                            color: Color(0xFF155DFC), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}