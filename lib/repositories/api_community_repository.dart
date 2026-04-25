// lib/repositories/api_community_repository.dart
//
// Fixes applied:
//  1. _commentFromApi: flexible JSON key parsing (userName/user_name/fullName/name,
//     userId/user_id/uid, parentCommentId/parent_comment_id/parentId).
//  2. getComments: rebuild nested tree from flat list using parentCommentId.
//  3. deleteComment: DELETE /api/Community/comments/{commentId}?userId={userId}
//  4. Community post endpoints unchanged.

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/models/CommunityModels/community_comment_model.dart';
import 'package:onboard/repositories/community_repository.dart';

// ─────────────────────────────────────────────
// 🔧 TOGGLE: set to true to use real backend API
// ─────────────────────────────────────────────
const bool useRealApi = true;

class ApiCommunityRepository implements ICommunityRepository {
  static const String _baseUrl = 'https://projecthubb.runasp.net';
  static bool _apiVerified = false;

  // ── Auth Token ──────────────────────────────
  Future<String?> _getToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      print('⚠️ Failed to get auth token: $e');
      return null;
    }
  }

  Map<String, String> _headers(String? token, {bool isJson = true}) {
    return {
      if (isJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _verifyOnce() {
    if (!_apiVerified) {
      _apiVerified = true;
      print('✅ API connected successfully — using real backend: $_baseUrl');
    }
  }

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'current_user';

  // ─────────────────────────────────────────────
  // GET /api/Community/posts?currentUserId={uid}
  // ─────────────────────────────────────────────
  @override
  Future<List<PostModel>> getPosts() async {
    final token = await _getToken();
    final uid = _currentUid;
    final uri = Uri.parse('$_baseUrl/api/Community/posts/')
        .replace(queryParameters: {'currentUserId': uid});

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      _verifyOnce();
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        print('📦 [GET POSTS] first post isLiked: ${data.first['isLiked']}');
      }
      final posts = data
          .map((json) => _postFromApi(json as Map<String, dynamic>))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } else {
      throw Exception(
          'GET /api/Community/posts failed: ${response.statusCode} ${response.body}');
    }
  }

  // ─────────────────────────────────────────────
  // GET /api/Community/my-posts/{userId}
  // ─────────────────────────────────────────────
  @override
  Future<List<PostModel>> getMyPosts(String userId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/my-posts/$userId');

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      _verifyOnce();
      final List<dynamic> data = jsonDecode(response.body);
      final posts = data
          .map((json) => _postFromApi(json as Map<String, dynamic>))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } else {
      throw Exception(
          'GET /api/Community/my-posts/$userId failed: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────
  // POST /api/Community/posts  (multipart/form-data)
  // ─────────────────────────────────────────────
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
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/posts/');

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final fullContent = hashtags.isNotEmpty
        ? '$content\n${hashtags.join(' ')}'
        : content;

    request.fields['Content'] = fullContent;
    request.fields['Visibility'] = _visibilityToString(visibility);
    request.fields['UserId'] = userId;

    if (attachmentName != null && attachmentName.isNotEmpty) {
      final file = File(attachmentName);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('PostImage', file.path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('📦 [CREATE POST] status: ${response.statusCode}');
    print('📦 [CREATE POST] body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      _verifyOnce();
      final dynamic data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && !data.containsKey('id') && !data.containsKey('postId')) {
          return _stubPost('0', '');
        }
        return _postFromApi(data);
      }
      return _stubPost('0', '');
    } else {
      throw Exception(
          'POST /api/Community/posts failed: ${response.statusCode} ${response.body}');
    }
  }

  // ─────────────────────────────────────────────
  // POST /api/Community/posts/{postId}/like
  // ─────────────────────────────────────────────
  @override
  Future<PostModel> toggleLike(String postId, String currentUserId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/posts/$postId/like/');

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(currentUserId),
    );

    print('📦 [TOGGLE LIKE] response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      _verifyOnce();
      if (response.body.isNotEmpty && response.body != 'null') {
        try {
          final dynamic data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return _postFromApi(data);
          }
        } catch (_) {}
      }
      return _stubPost(postId, currentUserId);
    } else {
      throw Exception(
          'POST /api/Community/posts/$postId/like failed: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────
  // DELETE /api/Community/posts/{postId}?userId={userId}
  // ─────────────────────────────────────────────
  @override
  Future<void> deletePost(String postId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/posts/$postId')
        .replace(queryParameters: {'userId': _currentUid});

    final response = await http.delete(uri, headers: _headers(token));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'DELETE /api/Community/posts/$postId failed: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────
  // GET /api/Community/posts/{postId}/comments
  // ✅ FIX: rebuild nested tree from flat list using parentCommentId
  // ─────────────────────────────────────────────
  @override
  Future<List<CommunityCommentModel>> getComments(String postId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/posts/$postId/comments');

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      _verifyOnce();
      final List<dynamic> data = jsonDecode(response.body);

      // Debug: print first comment JSON to see actual keys
      if (data.isNotEmpty) {
        print('🔍 [GET COMMENTS] first comment JSON: ${data.first}');
      }

      // Parse all comments (flat list from API)
      final List<CommunityCommentModel> flat = data
          .map((json) => _commentFromApi(json as Map<String, dynamic>, postId: postId))
          .toList();

      // ✅ Rebuild tree: separate top-level from replies
      return _buildCommentTree(flat);
    } else {
      throw Exception(
          'GET /api/Community/posts/$postId/comments failed: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────
  // POST /api/Community/comments
  // ─────────────────────────────────────────────
  @override
  Future<CommunityCommentModel> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/comments');

    final int postIdInt = int.tryParse(postId) ?? 0;

    final body = jsonEncode({
      'content': content,
      'postId': postIdInt,
      'userId': userId,
      if (parentCommentId != null && parentCommentId.isNotEmpty)
        'parentCommentId': int.tryParse(parentCommentId) ?? 0,
    });

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _verifyOnce();
      final dynamic data = jsonDecode(response.body);
      return _commentFromApi(
        data as Map<String, dynamic>,
        postId: postId,
        fallbackUserName: userName,
        fallbackUserId: userId,
      );
    } else {
      throw Exception(
          'POST /api/Community/comments failed: ${response.statusCode} ${response.body}');
    }
  }

  // ─────────────────────────────────────────────
  // ✅ NEW: DELETE /api/Community/comments/{commentId}?userId={userId}
  // ─────────────────────────────────────────────
  @override
  Future<void> deleteComment(String commentId, String userId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/comments/$commentId')
        .replace(queryParameters: {'userId': userId});

    print('🗑️ [DELETE COMMENT] commentId: $commentId  userId: $userId');
    print('🗑️ [DELETE COMMENT] uri: $uri');

    final response = await http.delete(uri, headers: _headers(token));

    print('🗑️ [DELETE COMMENT] status: ${response.statusCode}');
    print('🗑️ [DELETE COMMENT] body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'DELETE /api/Community/comments/$commentId failed: ${response.statusCode} ${response.body}');
    }
  }

  // ─────────────────────────────────────────────
  // Not in Swagger spec
  // ─────────────────────────────────────────────
  @override
  Future<CommunityCommentModel> toggleCommentLike(
      String postId, String commentId) async {
    throw UnimplementedError(
        'toggleCommentLike is not available in the backend API');
  }

  @override
  Future<PostModel> updateVisibility(
      String postId, PostVisibility visibility) async {
    throw UnimplementedError(
        'updateVisibility is not in the backend API — optimistic update only');
  }

  // ─────────────────────────────────────────────
  // MAPPING: API JSON → PostModel
  // ─────────────────────────────────────────────
  PostModel _postFromApi(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['postId'] ?? 0).toString();
    final userId = (json['user_id'] ?? json['userId'] ?? '').toString();
    final userName =
        (json['user_name'] ?? json['userName'] ?? json['fullName'] ?? '').toString();
    final content = (json['content'] ?? '').toString();
    final likes = (json['likes'] ?? json['likesCount'] ?? 0) as int;
    final commentsCount =
        (json['comments_count'] ?? json['commentsCount'] ?? 0) as int;
    final isLiked = (json['is_liked'] ?? json['isLiked'] ?? false) as bool;

    List<String> likedByUserIds = [];
    final likedRaw = json['liked_by_user_ids'] ?? json['likedByUserIds'] ?? json['likedByUsers'];
    if (likedRaw is List) {
      likedByUserIds = likedRaw.map((e) => e.toString()).toList();
    }

    List<String> hashtags = [];
    if (json['hashtags'] is List) {
      hashtags = List<String>.from(json['hashtags'] as List);
    } else {
      final regex = RegExp(r'#\w+');
      hashtags = regex.allMatches(content).map((m) => m.group(0)!).toList();
    }

    final visibilityStr =
        (json['visibility'] ?? json['postVisibility'] ?? 'public')
            .toString()
            .toLowerCase();

    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final avatarColor =
        (json['user_avatar_color'] ?? json['userAvatarColor'] ?? '#DBEAFE').toString();

    DateTime createdAt;
    try {
      String? rawTime = json['created_at'] ?? json['createdAt'] ?? json['time_ago'];
      if (rawTime != null && rawTime.isNotEmpty) {
        final hasTimezone = rawTime.endsWith('Z') ||
            RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(rawTime);
        if (!hasTimezone) rawTime += 'Z';
        createdAt = DateTime.parse(rawTime).toLocal();
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    final attachmentName = (json['post_image'] ??
                            json['postImage'] ??
                            json['postImageUrl'] ??
                            json['imageUrl'] ??
                            json['attachmentName'])?.toString();

    return PostModel(
      id: id,
      userId: userId,
      userName: userName,
      userInitial: userInitial,
      userAvatarColor: avatarColor,
      createdAt: createdAt,
      content: content,
      hashtags: hashtags,
      likes: likes,
      commentsCount: commentsCount,
      attachmentName: attachmentName,
      isLiked: isLiked,
      likedByUserIds: likedByUserIds,
      visibility: _visibilityFromString(visibilityStr),
    );
  }

  // ─────────────────────────────────────────────
  // ✅ FIXED: MAPPING: API JSON → CommunityCommentModel
  // Tries multiple key variants for userName, userId, parentCommentId
  // ─────────────────────────────────────────────
  CommunityCommentModel _commentFromApi(
    Map<String, dynamic> json, {
    required String postId,
    String? fallbackUserName,
    String? fallbackUserId,
  }) {
    // ✅ Flexible ID parsing
    final id = (json['id'] ?? json['commentId'] ?? 0).toString();

    // ✅ Flexible userName parsing — try all possible key names
    final userName = (() {
      for (final key in ['userName', 'user_name', 'fullName', 'name']) {
        final v = json[key];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return fallbackUserName ?? '';
    })();

    // ✅ Flexible userId parsing
    final userId = (() {
      for (final key in ['userId', 'user_id', 'uid']) {
        final v = json[key];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return fallbackUserId ?? '';
    })();

    // ✅ Flexible parentCommentId parsing
    final parentIdRaw = (() {
      for (final key in ['parentCommentId', 'parent_comment_id', 'parentId']) {
        final v = json[key];
        if (v != null) return v.toString().trim();
      }
      return '';
    })();
    final parentCommentId = (parentIdRaw.isEmpty || parentIdRaw == '0' || parentIdRaw == 'null')
        ? null
        : parentIdRaw;

    final content = (json['content'] ?? json['text'] ?? '').toString();

    DateTime createdAt;
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    if (createdAtRaw != null) {
      try {
        String raw = createdAtRaw.toString();
        if (!raw.endsWith('Z') && !raw.contains('+') && !raw.contains('-', 10)) {
          raw += 'Z';
        }
        createdAt = DateTime.parse(raw).toLocal();
      } catch (_) {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    final likes = (json['likes'] ?? json['likesCount'] ?? 0) as int;
    final isLiked = json['isLiked'] as bool? ?? false;
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return CommunityCommentModel(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      userInitial: userInitial,
      content: content,
      createdAt: createdAt,
      likes: likes,
      isLiked: isLiked,
      parentCommentId: parentCommentId,
    );
  }

  // ─────────────────────────────────────────────
  // ✅ NEW: Build nested comment tree from flat API list
  // Top-level: parentCommentId == null
  // Replies: parentCommentId == some top-level id
  // ─────────────────────────────────────────────
  List<CommunityCommentModel> _buildCommentTree(List<CommunityCommentModel> flat) {
    // Map id → comment for quick lookup
    final Map<String, CommunityCommentModel> byId = {
      for (final c in flat) c.id: c,
    };

    // Separate top-level vs replies
    final topLevel = <CommunityCommentModel>[];
    final replyMap  = <String, List<CommunityCommentModel>>{};

    for (final c in flat) {
      if (c.parentCommentId == null) {
        topLevel.add(c);
      } else {
        replyMap.putIfAbsent(c.parentCommentId!, () => []).add(c);
      }
    }

    // Attach replies to their parents
    return topLevel.map((parent) {
      final replies = replyMap[parent.id] ?? [];
      return parent.copyWith(replies: List<CommunityCommentModel>.from(replies));
    }).toList();
  }

  PostModel _stubPost(String postId, String userId) => PostModel(
        id: postId,
        userId: userId,
        userName: '',
        userInitial: '',
        userAvatarColor: '#DBEAFE',
        createdAt: DateTime.now(),
        content: '',
        hashtags: const [],
        likes: 0,
        commentsCount: 0,
        likedByUserIds: const [],
      );

  // ─────────────────────────────────────────────
  // UTILITY
  // ─────────────────────────────────────────────
  String _visibilityToString(PostVisibility v) {
    switch (v) {
      case PostVisibility.public:
        return 'public';
      case PostVisibility.myTeam:
        return 'myTeam';
      case PostVisibility.onlyMe:
        return 'onlyMe';
    }
  }

  PostVisibility _visibilityFromString(String s) {
    switch (s) {
      case 'myteam':
      case 'my_team':
      case 'team':
        return PostVisibility.myTeam;
      case 'onlyme':
      case 'only_me':
      case 'private':
        return PostVisibility.onlyMe;
      default:
        return PostVisibility.public;
    }
  }
}