// lib/models/comment_model.dart
class CommentModel {
  final String id;
  final String userName;
  final String userInitial;
  final String content;
  final String timeAgo;
  int likes;
  bool isLiked;
  final List<CommentModel>? replies;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.content,
    required this.timeAgo,
    this.likes = 0,
    this.isLiked = false,
    this.replies,
  });

  // Mock data for comments
  static List<CommentModel> mockComments = [
    CommentModel(
      id: '1',
      userName: 'Alex',
      userInitial: 'A',
      content: 'This sounds interesting! I have experience with health app design. Would love to discuss.',
      timeAgo: '1h ago',
      likes: 8,
    ),
    CommentModel(
      id: '2',
      userName: 'Sara',
      userInitial: 'S',
      content: 'I\'m working on a similar project. Maybe we can collaborate or share insights?',
      timeAgo: '1h ago',
      likes: 5,
    ),
  ];

  // For Firebase (later)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userInitial': userInitial,
      'content': content,
      'timeAgo': timeAgo,
      'likes': likes,
      'isLiked': isLiked,
      'replies': replies?.map((r) => r.toMap()).toList(),
    };
  }

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    return CommentModel(
      id: id,
      userName: map['userName'] ?? '',
      userInitial: map['userInitial'] ?? '',
      content: map['content'] ?? '',
      timeAgo: map['timeAgo'] ?? '',
      likes: map['likes'] ?? 0,
      isLiked: map['isLiked'] ?? false,
      replies: map['replies'] != null
          ? (map['replies'] as List)
              .map((r) => CommentModel.fromMap(r['id'], r))
              .toList()
          : null,
    );
  }
}