// lib/repositories/api_community_repository.dart
//
// Real backend integration for Community module.
// Base URL: http://projecthubb.runasp.net
//
// Toggle: set `useRealApi = true` to switch from mock to real API.
// Verification: console prints "✅ API connected successfully" on first successful fetch.

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
  // Interface signature: Future<List<PostModel>> getPosts()
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
      return data
          .map((json) => _postFromApi(json as Map<String, dynamic>))
          .toList();
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
      return data
          .map((json) => _postFromApi(json as Map<String, dynamic>))
          .toList();
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
      return _postFromApi(data as Map<String, dynamic>);
    } else {
      throw Exception(
          'POST /api/Community/posts failed: ${response.statusCode} ${response.body}');
    }
  }

  // ─────────────────────────────────────────────
  // POST /api/Community/posts/{postId}/like
  // Body per Swagger: plain JSON string (the userId)
  // ─────────────────────────────────────────────
  @override
  Future<PostModel> toggleLike(String postId, String currentUserId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/posts/$postId/like/');
    print('🔍 [TOGGLE LIKE] postId: $postId');
    print('🔍 [TOGGLE LIKE] currentUserId: $currentUserId');
    print('🔍 [TOGGLE LIKE] token: ${await _getToken()}');

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(currentUserId),
    );

    print('📦 [TOGGLE LIKE] response status: ${response.statusCode}');
    print('📦 [TOGGLE LIKE] response body: ${response.body}');

    if (response.statusCode == 200) {
      _verifyOnce();
      if (response.body.isNotEmpty && response.body != 'null') {
        try {
          final dynamic data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return _postFromApi(data);
          }
        } catch (_) {
          // body wasn't a post — CommunityCubit already applied optimistic
        }
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
  // ─────────────────────────────────────────────
  @override
  Future<List<CommunityCommentModel>> getComments(String postId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/posts/$postId/comments');

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      _verifyOnce();
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) =>
              _commentFromApi(json as Map<String, dynamic>, postId: postId))
          .toList();
    } else {
      throw Exception(
          'GET /api/Community/posts/$postId/comments failed: ${response.statusCode}');
    }
  }

  // ─────────────────────────────────────────────
  // POST /api/Community/comments
  // Body: { "content": "...", "postId": 123, "userId": "..." }
  // ─────────────────────────────────────────────
  @override
  Future<CommunityCommentModel> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/api/Community/comments');

    final int postIdInt = int.tryParse(postId) ?? 0;

    final body = jsonEncode({
      'content': content,
      'postId': postIdInt,
      'userId': userId,
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
      );
    } else {
      throw Exception(
          'POST /api/Community/comments failed: ${response.statusCode} ${response.body}');
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
    // No endpoint in spec — CommunityCubit handles this optimistically
    throw UnimplementedError(
        'updateVisibility is not in the backend API — optimistic update only');
  }

  // ─────────────────────────────────────────────
  // MAPPING: API JSON → PostModel
  // ─────────────────────────────────────────────
  PostModel _postFromApi(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['postId'] ?? 0).toString();
    final userId = (json['userId'] ?? json['user_id'] ?? '').toString();
    final userName =
        (json['userName'] ?? json['user_name'] ?? json['fullName'] ?? '')
            .toString();
    final content = (json['content'] ?? '').toString();
    final likes = (json['likes'] ?? json['likesCount'] ?? 0) as int;
    final commentsCount =
        (json['commentsCount'] ?? json['comments_count'] ?? 0) as int;
    final isLiked = json['isLiked'] as bool? ?? false;

    List<String> likedByUserIds = [];
    if (json['likedByUserIds'] is List) {
      likedByUserIds = List<String>.from(
          (json['likedByUserIds'] as List).map((e) => e.toString()));
    } else if (json['likedByUsers'] is List) {
      likedByUserIds = List<String>.from(
          (json['likedByUsers'] as List).map((e) => e.toString()));
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
        (json['userAvatarColor'] ?? json['user_avatar_color'] ?? '#DBEAFE')
            .toString();
    final timeAgo = _formatTimeAgo(json['createdAt'] ?? json['created_at']);
    final attachmentName =
        (json['attachmentName'] ?? json['postImageUrl'] ?? json['imageUrl'])
            ?.toString();

    return PostModel(
      id: id,
      userId: userId,
      userName: userName,
      userInitial: userInitial,
      userAvatarColor: avatarColor,
      timeAgo: timeAgo,
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
  // MAPPING: API JSON → CommunityCommentModel
  // ─────────────────────────────────────────────
  CommunityCommentModel _commentFromApi(
    Map<String, dynamic> json, {
    required String postId,
    String? fallbackUserName,
  }) {
    final id = (json['id'] ?? json['commentId'] ?? 0).toString();
    final userName =
        (json['userName'] ?? json['user_name'] ?? json['fullName'] ?? fallbackUserName ?? '')
            .toString();
    final content = (json['content'] ?? json['text'] ?? '').toString();
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
        : DateTime.now();
    final likes = (json['likes'] ?? json['likesCount'] ?? 0) as int;
    final isLiked = json['isLiked'] as bool? ?? false;
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return CommunityCommentModel(
      id: id,
      postId: postId,
      userName: userName,
      userInitial: userInitial,
      content: content,
      createdAt: createdAt,
      likes: likes,
      isLiked: isLiked,
    );
  }

  PostModel _stubPost(String postId, String userId) => PostModel(
        id: postId,
        userId: userId,
        userName: '',
        userInitial: '',
        userAvatarColor: '#DBEAFE',
        timeAgo: '',
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

  String _formatTimeAgo(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}