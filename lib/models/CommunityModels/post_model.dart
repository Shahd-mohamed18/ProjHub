enum PostVisibility { public, myTeam, onlyMe }

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userInitial;
  final String userAvatarColor;
  final DateTime createdAt;        // ✅ الوقت الفعلي
  final String content;
  final List<String> hashtags;
  final int likes;
  final int commentsCount;
  final String? attachmentName;
  final bool isLiked;
  final List<String> likedByUserIds;
  final PostVisibility visibility;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.userAvatarColor,
    required this.createdAt,       // ✅ إجباري
    required this.content,
    required this.hashtags,
    required this.likes,
    required this.commentsCount,
    this.attachmentName,
    this.isLiked = false,
    this.likedByUserIds = const [],
    this.visibility = PostVisibility.public,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return diff.inDays == 1 ? 'Yesterday' : '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  bool isLikedBy(String currentUserId) => likedByUserIds.contains(currentUserId);

  PostModel copyWith({
    bool? isLiked,
    int? likes,
    List<String>? likedByUserIds,
    int? commentsCount,
    String? content,
    List<String>? hashtags,
    String? attachmentName,
    PostVisibility? visibility,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      userName: userName,
      userInitial: userInitial,
      userAvatarColor: userAvatarColor,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      attachmentName: attachmentName ?? this.attachmentName,
      isLiked: isLiked ?? this.isLiked,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      visibility: visibility ?? this.visibility,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final name = json['user_name'] as String? ?? '';
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] ?? json['createdAt'] ?? '');
    } catch (e) {
      createdAt = DateTime.now();
    }
    return PostModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      userName: name,
      userInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      userAvatarColor: json['user_avatar_color'] as String? ?? '#DBEAFE',
      createdAt: createdAt,
      content: json['content'] as String? ?? '',
      hashtags: List<String>.from(json['hashtags'] as List? ?? []),
      likes: json['likes'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      attachmentName: json['attachment_name'] as String?,
      isLiked: json['is_liked'] as bool? ?? false,
      likedByUserIds: List<String>.from(json['liked_by_user_ids'] as List? ?? []),
      visibility: PostVisibility.values.firstWhere(
        (v) => v.name == (json['visibility'] as String? ?? 'public'),
        orElse: () => PostVisibility.public,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_avatar_color': userAvatarColor,
        'created_at': createdAt.toIso8601String(),
        'content': content,
        'hashtags': hashtags,
        'likes': likes,
        'comments_count': commentsCount,
        'attachment_name': attachmentName,
        'is_liked': isLiked,
        'liked_by_user_ids': likedByUserIds,
        'visibility': visibility.name,
      };

  static List<PostModel> get mockPosts => [
        PostModel(
          id: 'post_001',
          userId: 'user_marwa',
          userName: 'Marwa Mohamed',
          userInitial: 'M',
          userAvatarColor: '#DBEAFE',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          content: 'Looking for a UI/UX collaborator for a health app. DM if interested!',
          hashtags: ['#UIUX', '#HealthTech', '#Collaboration'],
          likes: 45,
          commentsCount: 12,
          likedByUserIds: ['user_alex', 'user_sara'],
        ),
        PostModel(
          id: 'post_002',
          userId: 'user_faten',
          userName: 'Faten Hesham',
          userInitial: 'F',
          userAvatarColor: '#DBEAFE',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          content: 'Sharing our project progress dashboard 📊\nBuilt with React and Chart.js.',
          hashtags: ['#UIUX', '#Analytical', '#Collaboration'],
          likes: 37,
          commentsCount: 120,
          attachmentName: 'dashboard_preview.png',
          likedByUserIds: [],
        ),
      ];
}