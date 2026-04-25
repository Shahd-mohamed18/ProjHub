// lib/cubits/community/community_comments_cubit.dart
//
// Changes:
//  1. addComment: passes parentCommentId to repository.
//  2. deleteComment: optimistic removal from top-level list AND nested replies.
//     Uses List.from() to avoid "unmodifiable list" errors.
//  3. toggleCommentLike: unchanged.

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
      emit(CommentsPostLoaded(
        comments: comments,
        totalCount: comments.length,
      ));
    } catch (e) {
      emit(CommentsPostError('Failed to load comments: ${e.toString()}'));
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? replyToCommentId,   // parent comment id for nesting
    String? replyToName,        // display name of the replied-to user
  }) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    // ✅ Optimistic: show immediately with correct local user name
    final optimisticComment = CommunityCommentModel.create(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: userId,
      userName: userName.isNotEmpty ? userName : 'You',
      content: content,
      replyToName: replyToName,
      parentCommentId: replyToCommentId,
    );

    // If this is a reply, nest it inside the parent comment; else append to list
    List<CommunityCommentModel> updatedComments;
    if (replyToCommentId != null) {
      // ✅ Use List.from() to avoid unmodifiable list errors
      updatedComments = currentState.comments.map((c) {
        if (c.id == replyToCommentId) {
          return c.copyWith(replies: List<CommunityCommentModel>.from([...c.replies, optimisticComment]));
        }
        return c;
      }).toList();
    } else {
      updatedComments = List<CommunityCommentModel>.from([...currentState.comments, optimisticComment]);
    }

    emit(CommentsPostLoaded(
      comments: updatedComments,
      totalCount: currentState.totalCount + 1,
      isSending: true,
    ));

    try {
      final newComment = await _repository.addComment(
        postId: postId,
        content: content,
        userId: userId,
        userName: userName,
        parentCommentId: replyToCommentId,
      );

      // Keep local userName if server returned empty
      final serverComment = newComment.userName.isNotEmpty
          ? newComment.copyWith(replyToName: replyToName)
          : newComment.copyWith(
              userName: userName.isNotEmpty ? userName : 'You',
              userInitial: userName.isNotEmpty ? userName[0].toUpperCase() : 'Y',
              userId: userId,
              replyToName: replyToName,
            );

      final latestState = state;
      if (latestState is CommentsPostLoaded) {
        List<CommunityCommentModel> finalComments;
        if (replyToCommentId != null) {
          // Replace optimistic reply inside the parent
          finalComments = latestState.comments.map((c) {
            if (c.id == replyToCommentId) {
              final updatedReplies = List<CommunityCommentModel>.from(
                c.replies.map((r) => r.id == optimisticComment.id ? serverComment : r),
              );
              return c.copyWith(replies: updatedReplies);
            }
            return c;
          }).toList();
        } else {
          // Replace optimistic top-level comment
          finalComments = latestState.comments
              .map((c) => c.id == optimisticComment.id ? serverComment : c)
              .toList();
        }
        emit(CommentsPostLoaded(
          comments: finalComments,
          totalCount: latestState.totalCount,
          isSending: false,
        ));
      }
    } catch (e) {
      final latestState = state;
      if (latestState is CommentsPostLoaded) {
        emit(latestState.copyWith(isSending: false));
      }
    }
  }

  // ─────────────────────────────────────────────
  // ✅ NEW: deleteComment — optimistic removal + API call
  // ─────────────────────────────────────────────
  Future<void> deleteComment({
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    // Guard: skip if id is invalid (temp or "0")
    if (commentId.isEmpty || commentId == '0' || commentId.startsWith('temp_')) {
      return;
    }

    // ✅ Optimistic removal: remove from top-level list OR from nested replies
    // Always use List.from() to avoid unmodifiable list errors
    final updatedComments = _removeCommentById(currentState.comments, commentId);
    final newCount = (currentState.totalCount - 1).clamp(0, currentState.totalCount);

    emit(currentState.copyWith(
      comments: updatedComments,
      totalCount: newCount,
    ));

    try {
      await _repository.deleteComment(commentId, userId);
      print('✅ [DELETE COMMENT] success: commentId=$commentId');
    } catch (e) {
      print('❌ [DELETE COMMENT] failed: $e — reverting');
      // Revert: reload comments from server
      loadComments(postId);
    }
  }

  // ─────────────────────────────────────────────
  // Helper: remove comment by id from top-level or from any nested replies
  // Returns a new list (does NOT mutate originals)
  // ─────────────────────────────────────────────
  List<CommunityCommentModel> _removeCommentById(
      List<CommunityCommentModel> comments, String commentId) {
    // First check top-level removal
    final withoutTopLevel = comments
        .where((c) => c.id != commentId)
        .map((c) {
          // Also check nested replies
          final filteredReplies = List<CommunityCommentModel>.from(
            c.replies.where((r) => r.id != commentId),
          );
          // Only rebuild if something was removed from replies
          if (filteredReplies.length != c.replies.length) {
            return c.copyWith(replies: filteredReplies);
          }
          return c;
        })
        .toList();

    return withoutTopLevel;
  }

  // ─────────────────────────────────────────────
  // toggleCommentLike — Optimistic Update (unchanged)
  // ─────────────────────────────────────────────
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

    emit(currentState.copyWith(comments: updatedComments));

    try {
      // TODO: await _repository.toggleCommentLike(postId, commentId);
    } catch (_) {
      emit(currentState);
    }
  }
}