// lib/models/CommunityModels/community_comment_model.dart
import 'package:equatable/equatable.dart';

class CommunityCommentModel extends Equatable {
  final String id;
  final String? taskId;
  final String? postId;
  final String userName;
  final String userInitial;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;

  const CommunityCommentModel({
    required this.id,
    this.taskId,
    this.postId,
    required this.userName,
    required this.userInitial,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
  }) : assert(taskId != null || postId != null, 'Either taskId or postId must be provided');

  bool get isTaskComment => taskId != null;
  bool get isCommunityComment => postId != null;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  static List<CommunityCommentModel> mockTaskComments = [
    CommunityCommentModel(
      id: '1',
      taskId: '1',
      userName: 'Ahmed',
      userInitial: 'A',
      content: 'Great work! Keep it up.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CommunityCommentModel(
      id: '2',
      taskId: '1',
      userName: 'Sara',
      userInitial: 'S',
      content: 'I have some suggestions for improvement.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  static List<CommunityCommentModel> mockCommunityComments = [
    CommunityCommentModel(
      id: '101',
      postId: '1',
      userName: 'Mohamed',
      userInitial: 'M',
      content: 'This is really helpful! Thanks for sharing.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    CommunityCommentModel(
      id: '102',
      postId: '1',
      userName: 'Noura',
      userInitial: 'N',
      content: 'Can you explain more about the implementation?',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  static List<CommunityCommentModel> mockCommentsForPost(String postId) {
    return mockCommunityComments.where((c) => c.postId == postId).toList();
  }

  // ✅ الـ create method الجديد
  factory CommunityCommentModel.create({
    required String id,
    required String postId,
    required String userName,
    required String content,
  }) {
    return CommunityCommentModel(
      id: id,
      postId: postId,
      userName: userName,
      userInitial: userName.isNotEmpty ? userName[0] : 'U',
      content: content,
      createdAt: DateTime.now(),
      likes: 0,
      isLiked: false,
    );
  }

  CommunityCommentModel copyWith({
    String? id,
    String? taskId,
    String? postId,
    String? userName,
    String? userInitial,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
  }) {
    return CommunityCommentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      postId: postId ?? this.postId,
      userName: userName ?? this.userName,
      userInitial: userInitial ?? this.userInitial,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [id, taskId, postId, userName, content, createdAt, likes, isLiked];
}