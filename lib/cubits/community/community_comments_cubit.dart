// lib/cubits/community/community_comments_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_state.dart';
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
  }) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    emit(currentState.copyWith(isSending: true));
    try {
      final newComment = await _repository.addComment(
        postId: postId,
        content: content,
        userId: userId,
        userName: userName,
      );
      emit(CommentsPostLoaded(
        comments: [...currentState.comments, newComment],
        totalCount: currentState.totalCount + 1,
        isSending: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSending: false));
    }
  }

  // ✅ Toggle Like على كومنت - Optimistic Update
  Future<void> toggleCommentLike(String postId, String commentId) async {
    final currentState = state;
    if (currentState is! CommentsPostLoaded) return;

    // نعدل الـ UI فوراً (Optimistic)
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
      // لو فشل نرجع للـ state القديم
      emit(currentState);
    }
  }
}