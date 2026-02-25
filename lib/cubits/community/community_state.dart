// lib/cubits/community/community_state.dart
import 'package:equatable/equatable.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

class CommunityLoaded extends CommunityState {
  final List<PostModel> posts;
  final List<PostModel> myPosts;
  final String currentUserId; // 
  final bool isCreatingPost;

  const CommunityLoaded({
    required this.posts,
    required this.myPosts,
    this.currentUserId = 'current_user',
    this.isCreatingPost = false,
  });

  @override
  List<Object?> get props => [posts, myPosts, currentUserId, isCreatingPost];

  CommunityLoaded copyWith({
    List<PostModel>? posts,
    List<PostModel>? myPosts,
    String? currentUserId,
    bool? isCreatingPost,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      myPosts: myPosts ?? this.myPosts,
      currentUserId: currentUserId ?? this.currentUserId,
      isCreatingPost: isCreatingPost ?? this.isCreatingPost,
    );
  }
}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────
// States للـ Comments Screen
// ─────────────────────────────────────────────
abstract class CommentsPostState extends Equatable {
  const CommentsPostState();
  @override
  List<Object?> get props => [];
}

class CommentsPostInitial extends CommentsPostState {
  const CommentsPostInitial();
}

class CommentsPostLoading extends CommentsPostState {
  const CommentsPostLoading();
}

class CommentsPostLoaded extends CommentsPostState {
  final List<CommunityCommentModel> comments;
  final int totalCount;
  final bool isSending;

  const CommentsPostLoaded({
    required this.comments,
    required this.totalCount,
    this.isSending = false,
  });

  @override
  List<Object?> get props => [comments, totalCount, isSending];

  CommentsPostLoaded copyWith({
    List<CommunityCommentModel>? comments,
    int? totalCount,
    bool? isSending,
  }) {
    return CommentsPostLoaded(
      comments: comments ?? this.comments,
      totalCount: totalCount ?? this.totalCount,
      isSending: isSending ?? this.isSending,
    );
  }
}

class CommentsPostError extends CommentsPostState {
  final String message;
  const CommentsPostError(this.message);
  @override
  List<Object?> get props => [message];
}