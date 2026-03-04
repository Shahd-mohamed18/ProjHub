// lib/repositories/community_repository.dart
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';

abstract class ICommunityRepository {
  Future<List<PostModel>> getPosts();
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