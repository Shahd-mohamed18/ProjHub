// lib/repositories/mock_community_repository.dart
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';
import 'package:onboard/repositories/community_repository.dart';

class MockCommunityRepository implements ICommunityRepository {
  final List<PostModel> _posts = List.from(PostModel.mockPosts);

  @override
  Future<List<PostModel>> getPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_posts);
  }

  @override
  Future<List<PostModel>> getMyPosts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _posts.where((p) => p.userId == userId).toList();
  }

  @override
  Future<PostModel> createPost({
    required String content,
    required List<String> hashtags,
    required PostVisibility visibility,
    required String userId,
    required String userName,
    required String userInitial,
    String? attachmentName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newPost = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userInitial: userInitial,
      userAvatarColor: '#DBEAFE',
      timeAgo: 'Just now',
      content: content,
      hashtags: hashtags,
      likes: 0,
      commentsCount: 0,
      attachmentName: attachmentName,
      visibility: visibility,
      likedByUserIds: const [],
    );
    _posts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<PostModel> toggleLike(String postId, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final post = _posts[index];
    final alreadyLiked = post.likedByUserIds.contains(currentUserId);
    final updatedLikedBy = alreadyLiked
        ? post.likedByUserIds.where((id) => id != currentUserId).toList()
        : [...post.likedByUserIds, currentUserId];

    final updated = post.copyWith(
      isLiked: !alreadyLiked,
      likes: alreadyLiked ? post.likes - 1 : post.likes + 1,
      likedByUserIds: updatedLikedBy,
    );
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _posts.removeWhere((p) => p.id == postId);
  }

  @override
  Future<PostModel> updateVisibility(
      String postId, PostVisibility visibility) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    final updated = _posts[index].copyWith(visibility: visibility);
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<List<CommunityCommentModel>> getComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return CommunityCommentModel.mockCommentsForPost(postId);
  }

  @override
  Future<CommunityCommentModel> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CommunityCommentModel.create(
      id: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userName: userName,
      content: content,
    );
  }

  @override
  Future<CommunityCommentModel> toggleCommentLike(
      String postId, String commentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    throw UnimplementedError();
  }
}