// lib/cubits/community/community_cubit.dart
//
// Changes vs original:
//  1. Added decrementCommentCount() — called by CommentsScreen after a comment is deleted.
//  2. loadPosts now also loads the current user's team members so myTeam posts
//     from teammates are visible in the Discover feed.
//  3. ✅ FIX: loadPosts now also stores the current user's team IDs (myTeamIds)
//     in state. createPost now accepts/derives a teamId and sends it to the
//     repository — this was missing before, which is why "My Team" posts
//     never showed up for teammates (the backend had no TeamId to match on).
//  4. ✅ FIX: optimistic/local post objects now carry teamId too, so they look
//     correct immediately, and the final post merges the server's teamId
//     (falling back to what we sent) so it survives the round trip.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/community/community_state.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/community_repository.dart';
import 'package:onboard/repositories/api_community_repository.dart'; // ✅ NEW: for getTeamPosts
import 'package:onboard/services/team_api_service.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final ICommunityRepository _repository;
  final TeamApiService _teamApiService = TeamApiService();

  CommunityCubit(this._repository) : super(const CommunityInitial());

  // ── Reads the real Firebase UID ──────────────
  String get _realUid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'current_user';

  // ─────────────────────────────────────────────
  // loadPosts — loads posts + current user's team members for visibility
  // ✅ FIX: GET /api/Community/posts only ever returns "public" posts —
  // it does NOT include "myTeam" posts at all (confirmed against the live
  // backend). The only endpoint that returns myTeam posts is
  // GET /api/Community/team/{teamId}. So we now fetch that separately for
  // every team the user belongs to, and merge the results into the feed.
  // ─────────────────────────────────────────────
  Future<void> loadPosts({String? userId}) async {
    final uid = userId ?? _realUid;
    print('🆔 [CUBIT] currentUserId: $uid');

    emit(const CommunityLoading());
    try {
      // Step 1: load public posts, my posts, and the user's teams in parallel.
      final results = await Future.wait([
        _repository.getPosts(),
        _repository.getMyPosts(uid),
        _teamApiService.getMyTeams(uid).catchError((_) => []),
      ]);

      final publicPosts = (results[0] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLiked || p.isLikedBy(uid)))
          .toList();
      final myPosts = (results[1] as List<PostModel>)
          .map((p) => p.copyWith(isLiked: p.isLiked || p.isLikedBy(uid)))
          .toList();

      // Collect all teammate IDs from all teams the current user belongs to,
      // and also collect the team IDs themselves.
      final teamMemberIds = <String>{};
      final myTeamIds = <String>{};
      final teams = results[2] as List;
      for (final team in teams) {
        myTeamIds.add(team.id.toString());

        for (final member in team.members) {
          if (member.id != uid) teamMemberIds.add(member.id);
        }
        for (final assistant in team.assistants) {
          if (assistant.id != uid) teamMemberIds.add(assistant.id);
        }
        // Also include supervisor
        if (team.supervisorId != uid && team.supervisorId.isNotEmpty) {
          teamMemberIds.add(team.supervisorId);
        }
      }

      print('👥 [CUBIT] teamMemberIds: ${teamMemberIds.length} teammates');
      print('🏷️ [CUBIT] myTeamIds: $myTeamIds');

      // ✅ NEW Step 2: fetch myTeam posts for every team the user belongs
      // to, since GET /api/Community/posts never returns them.
      // Only works against the real API repository — the mock repo has no
      // team-posts concept, so we skip this when running on mock data.
      final List<PostModel> teamPosts = [];
      if (_repository is ApiCommunityRepository && myTeamIds.isNotEmpty) {
        final apiRepo = _repository as ApiCommunityRepository;
        final teamResults = await Future.wait(
          myTeamIds.map((tid) => apiRepo.getTeamPosts(tid).catchError((e) {
                print('⚠️ [CUBIT] getTeamPosts($tid) failed: $e');
                return <PostModel>[];
              })),
        );
        for (final list in teamResults) {
          teamPosts.addAll(list);
        }
        print('🏷️ [CUBIT] fetched ${teamPosts.length} myTeam posts from '
            '${myTeamIds.length} team(s)');
      }

      final mergedTeamPosts = teamPosts
          .map((p) => p.copyWith(isLiked: p.isLiked || p.isLikedBy(uid)))
          .toList();

      // ✅ Merge: public feed + myTeam posts, de-duplicated by id, newest first.
      final byId = <String, PostModel>{};
      for (final p in publicPosts) {
        byId[p.id] = p;
      }
      for (final p in mergedTeamPosts) {
        byId[p.id] = p; // myTeam post data wins if id collides
      }
      final mergedPosts = byId.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // ✅ Also fold any of the user's own myTeam posts into myPosts,
      // since GET /api/Community/my-posts/{userId} appears to exclude
      // myTeam posts too (observed empty even when the user has one).
      final myPostIds = myPosts.map((p) => p.id).toSet();
      final myExtraTeamPosts = mergedTeamPosts
          .where((p) => p.userId == uid && !myPostIds.contains(p.id));
      final mergedMyPosts = [...myPosts, ...myExtraTeamPosts]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(CommunityLoaded(
        posts: mergedPosts,
        myPosts: mergedMyPosts,
        currentUserId: uid,
        teamMemberIds: teamMemberIds.toList(),
        myTeamIds: myTeamIds.toList(),
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
  // ✅ FIX: now accepts an explicit teamId param. If not passed and
  // visibility is myTeam, falls back to the current state's primaryTeamId
  // (the first team the user belongs to). This teamId is forwarded to the
  // repository so the backend can actually scope the post to that team.
  // ─────────────────────────────────────────────
  Future<void> createPost({
    required String content,
    required List<String> hashtags,
    required PostVisibility visibility,
    String? attachmentName,
    String? userId,
    String? userName,
    String? userInitial,
    String? teamId, // ✅ NEW
  }) async {
    final currentState = state;
    if (currentState is! CommunityLoaded) return;

    final uid = userId ?? currentState.currentUserId;
    final name = (userName != null && userName.isNotEmpty)
        ? userName
        : (FirebaseAuth.instance.currentUser?.displayName ?? '');
    final initial = userInitial ??
        (name.isNotEmpty ? name[0].toUpperCase() : '?');

    // ✅ NEW: resolve which team this post belongs to.
    // Only relevant when visibility == myTeam; falls back to the user's
    // first/primary team if the caller didn't pass one explicitly.
    final resolvedTeamId = visibility == PostVisibility.myTeam
        ? (teamId ?? currentState.primaryTeamId)
        : null;

    if (visibility == PostVisibility.myTeam &&
        (resolvedTeamId == null || resolvedTeamId.isEmpty)) {
      print('⚠️ [CREATE POST] visibility is myTeam but no teamId could be '
          'resolved — post will be created without a team association and '
          'likely will NOT be visible to teammates.');
    }

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
      teamId: resolvedTeamId, // ✅ NEW
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
        teamId: resolvedTeamId, // ✅ NEW
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

          // ✅ NEW: prefer the server's teamId, fall back to what we sent —
          // some backends don't echo TeamId back on creation.
          final finalTeamId = (serverPost.teamId != null &&
                  serverPost.teamId!.isNotEmpty)
              ? serverPost.teamId
              : resolvedTeamId;

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
            teamId: finalTeamId, // ✅ NEW
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