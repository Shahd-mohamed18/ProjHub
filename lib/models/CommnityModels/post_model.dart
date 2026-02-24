// lib/models/post_model.dart

class CommentModel {
  final String id;
  final String userName;
  final String userInitial;
  final String timeAgo;
  final String content;
  int likes;
  bool isLiked;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.timeAgo,
    required this.content,
    this.likes = 0,
    this.isLiked = false,
  });

  // ✅ من البيك ايند هنعمل factory من JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      userName: json['userName'],
      userInitial: json['userName'][0].toUpperCase(),
      timeAgo: json['timeAgo'],
      content: json['content'],
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'timeAgo': timeAgo,
        'content': content,
        'likes': likes,
        'isLiked': isLiked,
      };

  // Mock data مؤقت لحد ما البيك ايند يجهز
  static List<CommentModel> mockComments = [
    CommentModel(
      id: 'c1',
      userName: 'Alex',
      userInitial: 'A',
      timeAgo: '1h ago',
      content: 'This sounds interesting! I have experience with health app design. Would love to discuss.',
      likes: 8,
    ),
    CommentModel(
      id: 'c2',
      userName: 'Sara',
      userInitial: 'S',
      timeAgo: '1h ago',
      content: "I'm working on a similar project. Maybe we can collaborate or share insights?",
      likes: 5,
    ),
  ];
}

class PostModel {
  final String id;
  final String userName;
  final String userInitial;
  final String userAvatarColor;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  int likes;
  int comments;
  final String? attachment;
  bool isLiked;

  PostModel({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.userAvatarColor,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.likes,
    required this.comments,
    this.attachment,
    this.isLiked = false,
  });

  // ✅ من البيك ايند هنعمل factory من JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userName: json['userName'],
      userInitial: (json['userName'] as String)[0].toUpperCase(),
      userAvatarColor: json['userAvatarColor'] ?? '#DBEAFE',
      timeAgo: json['timeAgo'],
      content: json['content'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      attachment: json['attachment'],
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userInitial': userInitial,
        'userAvatarColor': userAvatarColor,
        'timeAgo': timeAgo,
        'content': content,
        'hashtags': hashtags,
        'likes': likes,
        'comments': comments,
        'attachment': attachment,
        'isLiked': isLiked,
      };

  // Mock data مؤقت لحد ما البيك ايند يجهز
  static List<PostModel> mockPosts = [
    PostModel(
      id: '1',
      userName: 'Marwa Mohamed',
      userInitial: 'M',
      userAvatarColor: '#DBEAFE',
      timeAgo: '2h ago',
      content: 'Looking for a UI/UX collaborator for a health app. DM if interested!',
      hashtags: ['#UIUX', '#HealthTech', '#Collaboration'],
      likes: 45,
      comments: 12,
      isLiked: false,
    ),
    PostModel(
      id: '2',
      userName: 'Faten Hesham',
      userInitial: 'F',
      userAvatarColor: '#DBEAFE',
      timeAgo: '1h ago',
      content: 'Sharing our project progress dashboard 📊\nBuilt with React and Chart.js.',
      hashtags: ['#UIUX', '#Analytical', '#Collaboration'],
      likes: 37,
      comments: 120,
      attachment: 'dashboard_preview.png',
      isLiked: false,
    ),
  ];
}