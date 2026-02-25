// lib/cubits/comments/comments_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/comments/comments_state.dart';
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
      emit(CommentsLoaded(
        comments: [...currentState.comments, newComment],
        isSending: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isSending: false));
    }
  }
}