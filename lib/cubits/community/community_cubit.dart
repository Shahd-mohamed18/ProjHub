// lib/cubits/community/community_cubit.dart
//
// Changes vs original:
//  1. Added decrementCommentCount() — called by CommentsScreen after a comment is deleted.
//  All other code is identical to the original.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/community_repository.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final ICommunityRepository _repository;

  CommunityCubit(this._repository) : super(const CommunityInitial());

  // ── Reads the real Firebase UID ──────────────
  String get _realUid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'current_user';

  // ─────────────────────────────────────────────
  // loadPosts — always uses the real UID
  // ─────────────────────────────────────────────
  Future<void> loadPosts({String? userId}) async {
    final uid = userId ?? _realUid;
    print('🆔 [CUBIT] currentUserId: $uid');

    emit(const CommunityLoading());
    try {
      final results = await Future.wait([
        _repository.getPosts(),
        _repository.getMyPosts(uid),
      ]);

      final posts = (results[0] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLiked || p.isLikedBy(uid)))
          .toList();
      final myPosts = (results[1] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLiked || p.isLikedBy(uid)))
          .toList();

      emit(CommunityLoaded(
        posts: posts,
        myPosts: myPosts,
        currentUserId: uid,
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
            : _realUid);
    return loadPosts(userId: uid);
  }

  // ─────────────────────────────────────────────
  // toggleLike
  // ─────────────────────────────────────────────
  Future<void> toggleLike(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    final userId = currentState.currentUserId;
    print('🔍 [TOGGLE LIKE] using userId from state: $userId');

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
      if (updatedPost.id.isNotEmpty &&
          (updatedPost.content.isNotEmpty || updatedPost.userId.isNotEmpty)) {
        final latestState = state;
        if (latestState is CommunityLoaded) {
          emit(latestState.copyWith(
            posts: _updatePostInList(latestState.posts, updatedPost),
            myPosts: _updatePostInList(latestState.myPosts, updatedPost),
          ));
        }
      }
    } catch (e) {
      print('❌ [TOGGLE LIKE] failed: $e — reverting optimistic update');
      emit(currentState);
    }
  }

  // ─────────────────────────────────────────────
  // createPost
  // ─────────────────────────────────────────────
  Future<void> createPost({
    required String content,
    required List<String> hashtags,
    required PostVisibility visibility,
    String? attachmentName,
    String? userId,
    String? userName,
    String? userInitial,
  }) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    final uid = userId ?? currentState.currentUserId;
    final name = (userName != null && userName.isNotEmpty)
        ? userName
        : (FirebaseAuth.instance.currentUser?.displayName ?? '');
    final initial = userInitial ??
        (name.isNotEmpty ? name[0].toUpperCase() : '?');

    final localCreatedAt = DateTime.now();
    final localPost = PostModel(
      id: 'temp_${localCreatedAt.millisecondsSinceEpoch}',
      userId: uid,
      userName: name,
      userInitial: initial,
      userAvatarColor: '#DBEAFE',
      createdAt: localCreatedAt,
      content: content,
      hashtags: hashtags,
      likes: 0,
      commentsCount: 0,
      attachmentName: attachmentName,
      isLiked: false,
      likedByUserIds: const [],
      visibility: visibility,
    );

    emit(currentState.copyWith(
      posts: [localPost, ...currentState.posts],
      myPosts: [localPost, ...currentState.myPosts],
      isCreatingPost: true,
    ));

    try {
      final serverPost = await _repository.createPost(
        content: content,
        hashtags: hashtags,
        visibility: visibility,
        attachmentName: attachmentName,
        userId: uid,
        userName: name,
        userInitial: initial,
      );

      final latestState = state;
      if (latestState is CommunityLoaded) {
        final isRealPost = serverPost.id != '0' && serverPost.id.isNotEmpty;

        if (isRealPost) {
          final serverAttachment = serverPost.attachmentName;
          final finalAttachment = (serverAttachment != null &&
                  serverAttachment.isNotEmpty)
              ? serverAttachment
              : attachmentName;

          final finalPost = PostModel(
            id: serverPost.id,
            userId: serverPost.userId.isNotEmpty ? serverPost.userId : uid,
            userName: serverPost.userName.isNotEmpty ? serverPost.userName : name,
            userInitial: serverPost.userInitial.isNotEmpty ? serverPost.userInitial : initial,
            userAvatarColor: serverPost.userAvatarColor,
            createdAt: localCreatedAt,
            content: serverPost.content,
            hashtags: serverPost.hashtags,
            likes: serverPost.likes,
            commentsCount: serverPost.commentsCount,
            attachmentName: finalAttachment,
            isLiked: serverPost.isLiked,
            likedByUserIds: serverPost.likedByUserIds,
            visibility: serverPost.visibility,
          );
          emit(latestState.copyWith(
            posts: latestState.posts
                .map((p) => p.id == localPost.id ? finalPost : p)
                .toList(),
            myPosts: latestState.myPosts
                .map((p) => p.id == localPost.id ? finalPost : p)
                .toList(),
            isCreatingPost: false,
          ));
        } else {
          emit(latestState.copyWith(isCreatingPost: false));
          await refreshPosts(userId: uid);
        }
      }
    } catch (e) {
      print('❌ [CREATE POST] failed: $e');
      emit(currentState);
    } finally {
      final latestState = state;
      if (latestState is CommunityLoaded && latestState.isCreatingPost) {
        emit(latestState.copyWith(isCreatingPost: false));
      }
    }
  }

  // ─────────────────────────────────────────────
  // changePostVisibility
  // ─────────────────────────────────────────────
  Future<void> changePostVisibility(
      String postId, PostVisibility newVisibility) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    PostModel update(PostModel p) =>
        p.id == postId ? p.copyWith(visibility: newVisibility) : p;

    emit(currentState.copyWith(
      posts: currentState.posts.map(update).toList(),
      myPosts: currentState.myPosts.map(update).toList(),
    ));
  }

  // ─────────────────────────────────────────────
  // deletePost
  // ─────────────────────────────────────────────
  Future<void> deletePost(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    emit(currentState.copyWith(
      posts: currentState.posts.where((p) => p.id != postId).toList(),
      myPosts: currentState.myPosts.where((p) => p.id != postId).toList(),
    ));

    try {
      await _repository.deletePost(postId);
    } catch (e) {
      print('❌ [DELETE POST] failed: $e — reverting');
      emit(currentState);
    }
  }

  // ─────────────────────────────────────────────
  // incrementCommentCount — local optimistic
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // ✅ NEW: decrementCommentCount — called after comment deletion
  // ─────────────────────────────────────────────
  void decrementCommentCount(String postId) {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    PostModel updateCount(PostModel p) {
      if (p.id != postId) return p;
      final newCount = (p.commentsCount - 1).clamp(0, p.commentsCount);
      return p.copyWith(commentsCount: newCount);
    }

    emit(currentState.copyWith(
      posts: currentState.posts.map(updateCount).toList(),
      myPosts: currentState.myPosts.map(updateCount).toList(),
    ));
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
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