// lib/cubits/community/community_cubit.dart
//
// FIX: loadPosts() now reads the real Firebase UID from FirebaseAuth
// instead of defaulting to the hardcoded 'current_user' string.
// This real UID is then passed to every operation that needs it
// (toggleLike, createPost, addComment).

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
    // ✅ Use real Firebase UID, ignore the hardcoded default
    final uid = userId ?? _realUid;
    print('🆔 [CUBIT] currentUserId: $uid');

    emit(const CommunityLoading());
    try {
      final results = await Future.wait([
        _repository.getPosts(),
        _repository.getMyPosts(uid),
      ]);

      final posts = (results[0] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLikedBy(uid)))
          .toList();
      final myPosts = (results[1] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLikedBy(uid)))
          .toList();

      emit(CommunityLoaded(
        posts: posts,
        myPosts: myPosts,
        currentUserId: uid, // ✅ stored in state so every widget can read it
      ));
    } catch (e) {
      emit(CommunityError('Failed to load posts: ${e.toString()}'));
    }
  }

  Future<void> refreshPosts({String? userId}) async {
    final currentState = state;
    // ✅ Pull uid from state (set by loadPosts) or fall back to real Firebase UID
    final uid = userId ??
        (currentState is CommunityLoaded
            ? currentState.currentUserId
            : _realUid);
    return loadPosts(userId: uid);
  }

  // ─────────────────────────────────────────────
  // toggleLike — uses uid from CommunityLoaded state
  // ─────────────────────────────────────────────
  Future<void> toggleLike(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    // ✅ uid comes from state (set correctly by loadPosts)
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
      // Only replace if backend returned a meaningful post object
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
  // createPost — userId / userName read from caller (create_post_screen)
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

    // ✅ Prefer passed-in userId; fallback to uid stored in state
    final uid = userId ?? currentState.currentUserId;
    final name = userName ?? '';
    final initial =
        userInitial ?? (name.isNotEmpty ? name[0].toUpperCase() : '?');

    emit(currentState.copyWith(isCreatingPost: true));
    try {
      final newPost = await _repository.createPost(
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
        emit(latestState.copyWith(
          posts: [newPost, ...latestState.posts],
          myPosts: [newPost, ...latestState.myPosts],
          isCreatingPost: false,
        ));
      }
    } catch (e) {
      print('❌ [CREATE POST] failed: $e');
      final latestState = state;
      if (latestState is CommunityLoaded) {
        emit(latestState.copyWith(isCreatingPost: false));
      }
    }
  }

  // ─────────────────────────────────────────────
  // changePostVisibility — optimistic only (no backend endpoint)
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
  // deletePost — optimistic, then confirmed by backend
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
  // incrementCommentCount — local optimistic only
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