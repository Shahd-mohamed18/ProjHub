// lib/cubits/comments/comments_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/comments/comments_state.dart';
import 'package:onboard/repositories/api_task_repository.dart';
import 'package:onboard/repositories/task_repository.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final ITaskRepository _repository;

  CommentsCubit(this._repository) : super(const CommentsInitial());

  Future<void> loadComments(String taskId) async {
    emit(const CommentsLoading());
    try {
      final comments = await _repository.getCommentsForTask(taskId);
      emit(CommentsLoaded(comments: comments));
    } catch (e) {
      emit(CommentsError('Failed to load comments: ${e.toString()}'));
    }
  }

  Future<void> addComment({
    required String taskId,
    required String text,
    required String userId,
    required String userName,
  }) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    emit(currentState.copyWith(isSending: true));

    try {
      final newComment = await _repository.addComment(
        taskId: taskId,
        text: text,
        userId: userId,
        userName: userName,
      );

      // ✅ If the API returned "Unknown" / empty name, patch it with the real name
      final patched = (newComment.userName.isEmpty ||
              newComment.userName == 'Unknown')
          ? newComment.copyWith(userName: userName)
          : newComment;

      emit(CommentsLoaded(
        comments: [...currentState.comments, patched],
        isSending: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSending: false));
    }
  }

  /// DELETE /api/Tasks/comments/{commentId}?userId=
  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final currentState = state;
    if (currentState is! CommentsLoaded) return;

    // Optimistic removal
    final updated = currentState.comments
        .where((c) => c.id != commentId)
        .toList();
    emit(currentState.copyWith(comments: updated));

    try {
      if (_repository is ApiTaskRepository) {
        final api = _repository as ApiTaskRepository;
        final ok = await api.deleteComment(
          int.tryParse(commentId) ?? 0,
        );
        if (!ok) {
          // Roll back
          emit(currentState);
        }
      }
    } catch (_) {
      // Roll back on error
      emit(currentState);
    }
  }
}