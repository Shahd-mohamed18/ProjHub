// lib/repositories/community_repository.dart
//
// NOTE: getPosts() has NO parameters — the userId is read internally
// by ApiCommunityRepository from FirebaseAuth.instance.currentUser.
// CommunityCubit passes userId only to getMyPosts().

import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';

abstract class ICommunityRepository {
  /// Fetch all posts visible to the current user.
  /// Implementations obtain the current user ID internally (e.g. from FirebaseAuth).
  Future<List<PostModel>> getPosts();

  /// Fetch posts created by [userId].
  Future<List<PostModel>> getMyPosts(String userId);

  Future<PostModel> createPost({
    required String content,
    required List<String> hashtags,
    required PostVisibility visibility,
    required String userId,
    required String userName,
    required String userInitial,
    String? attachmentName,
  });

  Future<PostModel> toggleLike(String postId, String currentUserId);

  Future<void> deletePost(String postId);

  Future<PostModel> updateVisibility(String postId, PostVisibility visibility);

  Future<List<CommunityCommentModel>> getComments(String postId);

  Future<CommunityCommentModel> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
  });

  Future<CommunityCommentModel> toggleCommentLike(
      String postId, String commentId);
}