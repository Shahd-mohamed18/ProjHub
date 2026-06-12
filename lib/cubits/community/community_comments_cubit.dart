// lib/cubits/community/community_comments_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';
import 'package:onboard/repositories/community_repository.dart';

class CommunityCommentsCubit extends Cubit<CommentsPostState> {
  final ICommunityRepository _repository;

  CommunityCommentsCubit(this._repository) : super(const CommentsPostInitial());

  Future<void> loadComments(String postId) async {
    emit(const CommentsPostLoading());
    try {
      final comments = await _repository.getComments(postId);
      if (isClosed) return;
      emit(CommentsPostLoaded(
        comments: comments,
        totalCount: _countAll(comments),
      ));
    } catch (e) {
      if (isClosed) return;
      emit(CommentsPostError('Failed to load comments: ${e.toString()}'));
    }
  }

  // Count all comments including nested replies
  int _countAll(List<CommunityCommentModel> comments) {
    int count = comments.length;
    for (final c in comments) {
      count += c.replies.length;
    }
    return count;
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? replyToCommentId,
    String? replyToName,
  }) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    // Optimistic: add immediately with a temp id
    final optimisticComment = CommunityCommentModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: userId,       // We know the userId here — set it on optimistic
      userName: userName.isNotEmpty ? userName : 'You',
      content: content,
      replyToName: replyToName,
      parentCommentId: replyToCommentId,
    );

    List<CommunityCommentModel> updatedComments;
    if (replyToCommentId != null) {
      // Nest inside parent
      updatedComments = currentState.comments.map((c) {
        if (c.id == replyToCommentId) {
          return c.copyWith(
            replies: List<CommunityCommentModel>.from([...c.replies, optimisticComment]),
          );
        }
        return c;
      }).toList();
    } else {
      updatedComments = List<CommunityCommentModel>.from([
        ...currentState.comments,
        optimisticComment,
      ]);
    }

    if (isClosed) return;
    emit(CommentsPostLoaded(
      comments: updatedComments,
      totalCount: currentState.totalCount + 1,
      isSending: true,
    ));

    try {
      // API returns {message: "Comment added"} — no real id back.
      // We build the confirmed comment locally in the repository.
      final confirmedComment = await _repository.addComment(
        postId: postId,
        content: content,
        userId: userId,
        userName: userName,
        parentCommentId: replyToCommentId,
      );

      // Build final comment — preserve userId and replyToName
      final finalComment = confirmedComment.copyWith(
        userId: userId,
        userName: userName.isNotEmpty ? userName : 'You',
        userInitial: userName.isNotEmpty ? userName[0].toUpperCase() : 'Y',
        replyToName: replyToName,
        parentCommentId: replyToCommentId,
      );

      if (isClosed) return;
      final latestState = state;
      if (latestState is CommentsPostLoaded) {
        List<CommunityCommentModel> finalComments;
        if (replyToCommentId != null) {
          // Replace optimistic reply inside parent
          finalComments = latestState.comments.map((c) {
            if (c.id == replyToCommentId) {
              final updatedReplies = List<CommunityCommentModel>.from(
                c.replies.map((r) => r.id == optimisticComment.id ? finalComment : r),
              );
              return c.copyWith(replies: updatedReplies);
            }
            return c;
          }).toList();
        } else {
          // Replace optimistic top-level comment
          finalComments = latestState.comments
              .map((c) => c.id == optimisticComment.id ? finalComment : c)
              .toList();
        }
        emit(CommentsPostLoaded(
          comments: finalComments,
          totalCount: latestState.totalCount,
          isSending: false,
        ));
      }
    } catch (e) {
      // On error, reload from server to get accurate state
      if (isClosed) return;
      print('❌ [ADD COMMENT] failed: $e');
      loadComments(postId);
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    if (commentId.isEmpty || commentId == '0' || commentId.startsWith('temp_')) {
      return;
    }

    // Optimistic removal
    final updatedComments = _removeCommentById(currentState.comments, commentId);
    final newCount = (currentState.totalCount - 1).clamp(0, currentState.totalCount);

    if (isClosed) return;
    emit(currentState.copyWith(comments: updatedComments, totalCount: newCount));

    try {
      await _repository.deleteComment(commentId, userId);
      print('✅ [DELETE COMMENT] success: $commentId');
    } catch (e) {
      print('❌ [DELETE COMMENT] failed: $e — reverting');
      if (isClosed) return;
      loadComments(postId);
    }
  }

  List<CommunityCommentModel> _removeCommentById(
      List<CommunityCommentModel> comments, String commentId) {
    return comments
        .where((c) => c.id != commentId)
        .map((c) {
          final filteredReplies = List<CommunityCommentModel>.from(
            c.replies.where((r) => r.id != commentId),
          );
          if (filteredReplies.length != c.replies.length) {
            return c.copyWith(replies: filteredReplies);
          }
          return c;
        })
        .toList();
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    final updatedComments = currentState.comments.map((c) {
      if (c.id == commentId) {
        return c.copyWith(
          isLiked: !c.isLiked,
          likes: c.isLiked ? c.likes - 1 : c.likes + 1,
        );
      }
      return c;
    }).toList();

    if (isClosed) return;
    emit(currentState.copyWith(comments: updatedComments));
  }
}