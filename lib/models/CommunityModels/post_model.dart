// lib/models/CommunityModels/post_model.dart

enum PostVisibility { public, myTeam, onlyMe }

class PostModel {
  final String id;
  final String userId;            // ✅ لازم للـ like tracking و myPosts
  final String userName;
  final String userInitial;
  final String userAvatarColor;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final int likes;
  final int commentsCount;
  final String? attachmentName;
  final bool isLiked;
  final List<String> likedByUserIds; // ✅ قايمة مين عمل لايك فعلاً
  final PostVisibility visibility;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.userAvatarColor,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.likes,
    required this.commentsCount,
    this.attachmentName,
    this.isLiked = false,
    this.likedByUserIds = const [],
    this.visibility = PostVisibility.public,
  });

  /// ✅ بيحسب isLiked على حسب الـ currentUserId الفعلي
  bool isLikedBy(String currentUserId) => likedByUserIds.contains(currentUserId);

  PostModel copyWith({
    bool? isLiked,
    int? likes,
    List<String>? likedByUserIds,
    int? commentsCount,
    String? timeAgo,
    String? content,
    List<String>? hashtags,
    String? attachmentName,
    PostVisibility? visibility,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      userName: userName,
      userInitial: userInitial,
      userAvatarColor: userAvatarColor,
      timeAgo: timeAgo ?? this.timeAgo,
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
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: name,
      userInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      userAvatarColor: json['user_avatar_color'] as String? ?? '#DBEAFE',
      timeAgo: json['time_ago'] as String? ?? '',
      content: json['content'] as String,
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
        'time_ago': timeAgo,
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
        const PostModel(
          id: 'post_001',
          userId: 'user_marwa',
          userName: 'Marwa Mohamed',
          userInitial: 'M',
          userAvatarColor: '#DBEAFE',
          timeAgo: '2h ago',
          content:
              'Looking for a UI/UX collaborator for a health app. DM if interested!',
          hashtags: ['#UIUX', '#HealthTech', '#Collaboration'],
          likes: 45,
          commentsCount: 12,
          likedByUserIds: ['user_alex', 'user_sara'],
        ),
        const PostModel(
          id: 'post_002',
          userId: 'user_faten',
          userName: 'Faten Hesham',
          userInitial: 'F',
          userAvatarColor: '#DBEAFE',
          timeAgo: '1h ago',
          content:
              'Sharing our project progress dashboard 📊\nBuilt with React and Chart.js.',
          hashtags: ['#UIUX', '#Analytical', '#Collaboration'],
          likes: 37,
          commentsCount: 120,
          attachmentName: 'dashboard_preview.png',
          likedByUserIds: [],
        ),
      ];
}