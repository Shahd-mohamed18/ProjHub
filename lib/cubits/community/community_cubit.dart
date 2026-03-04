// lib/cubits/community/community_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/community_repository.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final ICommunityRepository _repository;

  CommunityCubit(this._repository) : super(const CommunityInitial());

  Future<void> loadPosts({String userId = 'current_user'}) async {
    emit(const CommunityLoading());
    try {
      final results = await Future.wait([
        _repository.getPosts(),
        _repository.getMyPosts(userId),
      ]);

      final posts = (results[0] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLikedBy(userId)))
          .toList();
      final myPosts = (results[1] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLikedBy(userId)))
          .toList();

      emit(CommunityLoaded(
        posts: posts,
        myPosts: myPosts,
        currentUserId: userId,
      ));
    } catch (e) {
      emit(CommunityError('Failed to load posts: ${e.toString()}'));
    }
  }

  Future<void> refreshPosts({String? userId}) async {
    final currentState = state;
    final uid = userId ??
        (currentState is CommunityLoaded
            ? currentState.currentUserId
            : 'current_user');
    return loadPosts(userId: uid);
  }

  // Toggle Like - Optimistic Update
  Future<void> toggleLike(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    final userId = currentState.currentUserId;

    final optimisticPosts =
        _toggleLikeInList(currentState.posts, postId, userId);
    final optimisticMyPosts =
        _toggleLikeInList(currentState.myPosts, postId, userId);
    emit(currentState.copyWith(
      posts: optimisticPosts,
      myPosts: optimisticMyPosts,
    ));

    try {
      final updatedPost = await _repository.toggleLike(postId, userId);
      emit(currentState.copyWith(
        posts: _updatePostInList(optimisticPosts, updatedPost),
        myPosts: _updatePostInList(optimisticMyPosts, updatedPost),
      ));
    } catch (_) {
      emit(currentState);
    }
  }

  // إنشاء Post جديد
  Future<void> createPost({
    required String content,
    required List<String> hashtags,
    required PostVisibility visibility,
    String? attachmentName,
    String userId = 'current_user',
    String userName = 'Marwa Mohamed',
    String userInitial = 'M',
  }) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    emit(currentState.copyWith(isCreatingPost: true));
    try {
      final newPost = await _repository.createPost(
        content: content,
        hashtags: hashtags,
        visibility: visibility,
        attachmentName: attachmentName,
        userId: userId,
        userName: userName,
        userInitial: userInitial,
      );

      final latestState = state;
      if (latestState is CommunityLoaded) {
        emit(latestState.copyWith(
          posts: [newPost, ...latestState.posts],
          myPosts: [newPost, ...latestState.myPosts],
          isCreatingPost: false,
        ));
      }
    } catch (e) {
      final latestState = state;
      if (latestState is CommunityLoaded) {
        emit(latestState.copyWith(isCreatingPost: false));
      }
    }
  }

  // ✅ تغيير visibility بوست موجود
  Future<void> changePostVisibility(
      String postId, PostVisibility newVisibility) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    // Optimistic update فوراً
    PostModel update(PostModel p) =>
        p.id == postId ? p.copyWith(visibility: newVisibility) : p;

    emit(currentState.copyWith(
      posts: currentState.posts.map(update).toList(),
      myPosts: currentState.myPosts.map(update).toList(),
    ));

    try {
      // TODO: PATCH /api/community/posts/{postId}/visibility
      // await _repository.updateVisibility(postId, newVisibility);
    } catch (_) {
      // لو فشل نرجع القديم
      emit(currentState);
    }
  }

  // ✅ حذف بوست
  Future<void> deletePost(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    // Optimistic - شيل فوراً من الـ UI
    emit(currentState.copyWith(
      posts: currentState.posts.where((p) => p.id != postId).toList(),
      myPosts: currentState.myPosts.where((p) => p.id != postId).toList(),
    ));

    try {
      // TODO: DELETE /api/community/posts/{postId}
      await _repository.deletePost(postId);
    } catch (_) {
      // لو فشل نرجع القديم
      emit(currentState);
    }
  }

  // زود عداد الكومنتات
  void incrementCommentCount(String postId) {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    PostModel updateCount(PostModel p) =>
        p.id == postId ? p.copyWith(commentsCount: p.commentsCount + 1) : p;

    emit(currentState.copyWith(
      posts: currentState.posts.map(updateCount).toList(),
      myPosts: currentState.myPosts.map(updateCount).toList(),
    ));
  }

  List<PostModel> _toggleLikeInList(
      List<PostModel> list, String postId, String userId) {
    return list.map((p) {
      if (p.id != postId) return p;
      final alreadyLiked = p.likedByUserIds.contains(userId);
      final updatedLikedBy = alreadyLiked
          ? p.likedByUserIds.where((id) => id != userId).toList()
          : [...p.likedByUserIds, userId];
      return p.copyWith(
        isLiked: !alreadyLiked,
        likes: alreadyLiked ? p.likes - 1 : p.likes + 1,
        likedByUserIds: updatedLikedBy,
      );
    }).toList();
  }

  List<PostModel> _updatePostInList(List<PostModel> list, PostModel updated) {
    return list.map((p) => p.id == updated.id ? updated : p).toList();
  }
}