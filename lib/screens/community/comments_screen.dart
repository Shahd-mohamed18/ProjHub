// lib/screens/community/comments_screen.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/chat/chat_cubit.dart';
import 'package:onboard/cubits/community/community_comments_cubit.dart';
import 'package:onboard/cubits/community/community_cubit.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/mock_community_repository.dart';
import 'package:onboard/repositories/api_community_repository.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';
import 'package:onboard/screens/chatScreens/chat_screen.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _replyingToName;
  String? _replyingToCommentId;

  String get _currentUserId =>
      context.read<AuthCubit>().state.userModel?.uid ?? '';

  String get _currentUserName =>
      context.read<AuthCubit>().state.userModel?.fullName ?? '';

  String get _currentUserPhotoUrl =>
      context.read<AuthCubit>().state.userModel?.photoUrl ?? '';

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(String userName, String commentId) {
    setState(() {
      _replyingToName = userName;
      _replyingToCommentId = commentId;
    });
    _commentController.text = '@$userName ';
    _focusNode.requestFocus();
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  void _cancelReply() {
    setState(() {
      _replyingToName = null;
      _replyingToCommentId = null;
    });
    _commentController.clear();
    _focusNode.unfocus();
  }

  void _confirmDeleteComment(
      BuildContext context, CommunityCommentsCubit cubit, String commentId) {
    if (commentId.isEmpty || commentId == '0' || commentId.startsWith('temp_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete this comment (not yet saved to server).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Comment',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this comment? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6A7282))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteComment(
                postId: widget.post.id,
                commentId: commentId,
                userId: _currentUserId,
              );
              try {
                context.read<CommunityCubit>().decrementCommentCount(widget.post.id);
              } catch (_) {}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = useRealApi
        ? ApiCommunityRepository()
        : MockCommunityRepository();

    return BlocProvider(
      create: (_) => CommunityCommentsCubit(repo)
        ..loadComments(widget.post.id),
      child: Scaffold(
        body: Container(
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
                        return RefreshIndicator(
                          onRefresh: () => context
                              .read<CommunityCommentsCubit>()
                              .loadComments(widget.post.id),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            children: [
                              SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No comments yet\nBe the first!',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<CommunityCommentsCubit>()
                            .loadComments(widget.post.id),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];
                            final cubit =
                                context.read<CommunityCommentsCubit>();
                            return _CommentCard(
                              comment: comment,
                              currentUserId: _currentUserId,
                              currentUserName: _currentUserName,
                              onLike: () => cubit.toggleCommentLike(
                                  widget.post.id, comment.id),
                              onReply: () =>
                                  _startReply(comment.userName, comment.id),
                              onDelete: () => _confirmDeleteComment(
                                  context, cubit, comment.id),
                              onDeleteReply: (replyId) =>
                                  _confirmDeleteComment(context, cubit, replyId),
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
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
        boxShadow: [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 1)),
        ],
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
                width: 40,
                height: 40,
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
            _PostAttachment(attachmentName: widget.post.attachmentName!),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                widget.post.isLiked
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 16,
                color: widget.post.isLiked
                    ? Colors.red
                    : const Color(0xFF6A7282),
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
        final isSending =
            state is CommentsPostLoaded && state.isSending;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
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
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : GestureDetector(
                      onTap: () => _sendComment(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const ShapeDecoration(
                            color: Color(0xFF155DFC),
                            shape: CircleBorder()),
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
    String text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_replyingToName != null) {
      final mention = '@$_replyingToName';
      if (text.startsWith(mention)) {
        text = text.substring(mention.length).trim();
      }
      if (text.isEmpty) return;
    }

    final userId = _currentUserId;
    final userName = _currentUserName.isNotEmpty
        ? _currentUserName
        : (FirebaseAuth.instance.currentUser?.displayName ?? '');
    final replyToCommentId = _replyingToCommentId;
    final replyToName = _replyingToName;
    final userPhotoUrl = _currentUserPhotoUrl;

    print('💬 [COMMENT] userId: $userId  userName: $userName  replyTo: $replyToCommentId  content: $text');

    _commentController.clear();
    _focusNode.unfocus();
    setState(() {
      _replyingToName = null;
      _replyingToCommentId = null;
    });

    context.read<CommunityCommentsCubit>().addComment(
          postId: widget.post.id,
          content: text,
          userId: userId,
          userName: userName,
          replyToCommentId: replyToCommentId,
          replyToName: replyToName,
          userPhotoUrl: userPhotoUrl,
        );

    try {
      context.read<CommunityCubit>().incrementCommentCount(widget.post.id);
    } catch (_) {}
  }
}

// ─── Comment Card ──────────────────────────────────────────────
class _CommentCard extends StatelessWidget {
  final CommunityCommentModel comment;
  final String currentUserId;
  final String currentUserName;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final void Function(String replyId)? onDeleteReply;

  const _CommentCard({
    required this.comment,
    required this.currentUserId,
    required this.currentUserName,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
    this.onDeleteReply,
  });

  bool get _isOwner {
    if (comment.userId.isNotEmpty && currentUserId.isNotEmpty) {
      return comment.userId == currentUserId;
    }
    return currentUserName.isNotEmpty &&
        comment.userName.isNotEmpty &&
        comment.userName.toLowerCase() == currentUserName.toLowerCase();
  }

  // ✅ دالة الانتقال إلى الشات – تبحث عن userId إذا لم يكن موجوداً
  void _goToChat(BuildContext context) async {
    // إذا كان userId موجوداً، استخدمه مباشرة
    if (comment.userId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: comment.userId,
            otherUserName: comment.userName,
            otherUserPhoto: comment.userPhotoUrl,
          ),
        ),
      );
      return;
    }

    // إذا لم يكن userId موجوداً، حاول البحث بالاسم
    final chatCubit = context.read<ChatCubit>();
    final foundUserId = await chatCubit.findUserIdByName(comment.userName);
    if (foundUserId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: foundUserId,
            otherUserName: comment.userName,
            otherUserPhoto: comment.userPhotoUrl,
          ),
        ),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find user to chat with.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(comment),
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
              // ✅ أيقونة الرسالة تظهر دائماً
              GestureDetector(
                onTap: () => _goToChat(context),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.message_outlined,
                    size: 18,
                    color: Color(0xFF155DFC),
                  ),
                ),
              ),
              if (_isOwner)
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      comment.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
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
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            ...comment.replies.map((reply) => _ReplyBubble(
                  reply: reply,
                  currentUserId: currentUserId,
                  currentUserName: currentUserName,
                  onDeleteReply: () => onDeleteReply?.call(reply.id),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(CommunityCommentModel comment) {
    final photo = comment.userPhotoUrl;
    if (photo != null && photo.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(photo),
        onBackgroundImageError: (_, __) => _fallbackAvatar(comment.userInitial),
        child: null,
      );
    } else {
      return _fallbackAvatar(comment.userInitial);
    }
  }

  Widget _fallbackAvatar(String initial) {
    return Container(
      width: 32,
      height: 32,
      decoration: const ShapeDecoration(
        color: Color(0xFFDBEAFE),
        shape: CircleBorder(),
      ),
      child: Center(
        child: Text(initial,
            style: const TextStyle(color: Color(0xFF155DFC), fontSize: 12)),
      ),
    );
  }
}

// ─── Reply Bubble ──────────────────────────────────────────────
class _ReplyBubble extends StatelessWidget {
  final CommunityCommentModel reply;
  final String currentUserId;
  final String currentUserName;
  final VoidCallback onDeleteReply;

  const _ReplyBubble({
    required this.reply,
    required this.currentUserId,
    required this.currentUserName,
    required this.onDeleteReply,
  });

  bool get _isOwner {
    if (reply.userId.isNotEmpty && currentUserId.isNotEmpty) {
      return reply.userId == currentUserId;
    }
    return currentUserName.isNotEmpty &&
        reply.userName.isNotEmpty &&
        reply.userName.toLowerCase() == currentUserName.toLowerCase();
  }

  void _goToChat(BuildContext context) async {
    if (reply.userId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: reply.userId,
            otherUserName: reply.userName,
            otherUserPhoto: reply.userPhotoUrl,
          ),
        ),
      );
      return;
    }

    final chatCubit = context.read<ChatCubit>();
    final foundUserId = await chatCubit.findUserIdByName(reply.userName);
    if (foundUserId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: foundUserId,
            otherUserName: reply.userName,
            otherUserPhoto: reply.userPhotoUrl,
          ),
        ),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find user to chat with.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: 36,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildAvatar(reply),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(reply.userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          if (reply.replyToName != null) ...[
                            const SizedBox(width: 4),
                            Text('→ @${reply.replyToName}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF155DFC))),
                          ],
                        ],
                      ),
                    ),
                    // ✅ أيقونة الرسالة تظهر دائماً للردود
                    GestureDetector(
                      onTap: () => _goToChat(context),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.message_outlined,
                          size: 16,
                          color: Color(0xFF155DFC),
                        ),
                      ),
                    ),
                    if (_isOwner)
                      GestureDetector(
                        onTap: onDeleteReply,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.delete_outline,
                              size: 15, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                Text(reply.timeAgo,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 3),
                Text(reply.content, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(CommunityCommentModel comment) {
    final photo = comment.userPhotoUrl;
    if (photo != null && photo.isNotEmpty) {
      return CircleAvatar(
        radius: 13,
        backgroundImage: NetworkImage(photo),
        onBackgroundImageError: (_, __) => _fallbackAvatar(comment.userInitial),
        child: null,
      );
    } else {
      return _fallbackAvatar(comment.userInitial);
    }
  }

  Widget _fallbackAvatar(String initial) {
    return Container(
      width: 26,
      height: 26,
      decoration: const ShapeDecoration(
        color: Color(0xFFDBEAFE),
        shape: CircleBorder(),
      ),
      child: Center(
        child: Text(initial,
            style: const TextStyle(color: Color(0xFF155DFC), fontSize: 10)),
      ),
    );
  }
}

// ─── Post Attachment ───────────────────────────────────────────
class _PostAttachment extends StatelessWidget {
  final String attachmentName;
  const _PostAttachment({required this.attachmentName});

  bool get _isNetworkImage =>
      attachmentName.startsWith('http://') ||
      attachmentName.startsWith('https://');

  bool get _isLocalFile =>
      attachmentName.startsWith('/') ||
      attachmentName.startsWith('file://');

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          attachmentName,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fileFallback(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 180,
              color: const Color(0xFFF3F4F6),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
    }
    if (_isLocalFile) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(attachmentName.replaceFirst('file://', '')),
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fileFallback(),
        ),
      );
    }
    return _fileFallback();
  }

  Widget _fileFallback() {
    return Container(
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
          Expanded(
            child: Text(
              attachmentName.split('/').last,
              style: const TextStyle(color: Color(0xFF4A5565), fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}