// lib/cubits/comments/comments_state.dart
import 'package:equatable/equatable.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();
  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final bool isSending;

  const CommentsLoaded({
    required this.comments,
    this.isSending = false,
  });

  @override
  List<Object?> get props => [comments, isSending];

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? isSending,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      isSending: isSending ?? this.isSending,
    );
  }
}

class CommentsError extends CommentsState {
  final String message;
  const CommentsError(this.message);
  @override
  List<Object?> get props => [message];
}