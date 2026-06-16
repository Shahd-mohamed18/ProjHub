// lib/widgets/tasks/task_details/comment_section.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/comments/comments_cubit.dart';
import 'package:onboard/cubits/comments/comments_state.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';

class CommentSection extends StatefulWidget {
  final String taskId;

  const CommentSection({super.key, required this.taskId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CommentsCubit>().loadComments(widget.taskId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    // ✅ Always use the real full name from AuthCubit
    final userName =
        context.read<AuthCubit>().state.userModel?.fullName ?? 'User';

    context.read<CommentsCubit>().addComment(
          taskId: widget.taskId,
          text: text,
          userId: uid,
          userName: userName,
        );

    _controller.clear();
  }

  void _confirmDeleteComment(BuildContext context, CommentModel comment) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dlg);
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              context.read<CommentsCubit>().deleteComment(
                    commentId: comment.id,
                    userId: uid,
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            if (state is CommentsLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (state is CommentsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is CommentsLoaded) {
              final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

              return Column(
                children: [
                  if (state.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No comments yet. Be the first!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...state.comments.map(
                      (c) => _buildCommentItem(context, c, currentUid),
                    ),
                  const SizedBox(height: 16),
                  _buildCommentInput(isSending: state.isSending),
                ],
              );
            }

            return _buildCommentInput(isSending: false);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(
      BuildContext context, CommentModel comment, String currentUid) {
    // ✅ Resolve display name: never show "Unknown" or empty
    final displayName = (comment.userName.isEmpty ||
            comment.userName.toLowerCase() == 'unknown')
        ? (comment.userId == currentUid
            ? (context.read<AuthCubit>().state.userModel?.fullName ?? 'You')
            : 'Team Member')
        : comment.userName;

    final isOwner = comment.userId == currentUid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: isOwner
                ? const Color(0xFFDBEAFE)
                : const Color(0xFFBFDBFE),
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isOwner ? const Color(0xFF155DFC) : const Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isOwner ? 'You' : displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.formattedTime,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    // ✅ Delete icon — only visible for the comment owner
                    if (isOwner) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            _confirmDeleteComment(context, comment),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text,
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput({required bool isSending}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isSending,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendComment(),
            ),
          ),
          IconButton(
            onPressed: isSending ? null : _sendComment,
            icon: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Color(0xFF2196F3)),
          ),
        ],
      ),
    );
  }
}