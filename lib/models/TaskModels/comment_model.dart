// lib/models/TaskModels/comment_model.dart
import 'package:intl/intl.dart';

class CommentModel {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(createdAt);
  }

  String get initial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  // ✅ copyWith so cubit can patch userName when API returns "Unknown"
  CommentModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? userName,
    String? text,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ✅ GET /api/tasks/{taskId}/comments
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // ── resolve userName from every possible key the backend uses ──
    final rawName = json['userName'] ??
        json['user_name'] ??
        json['authorName'] ??
        json['senderName'] ??
        json['fullName'] ??
        json['name'] ??
        '';

    return CommentModel(
      id: (json['id'] ?? '').toString(),
      taskId: (json['task_id'] ?? json['taskId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      userName: rawName.toString(),
      text: (json['text'] ?? json['content'] ?? '').toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'user_id': userId,
        'user_name': userName,
        'text': text,
        'created_at': createdAt.toIso8601String(),
      };

  // ✅ Mock Data
  static List<CommentModel> mockCommentsForTask(String taskId) => [
        CommentModel(
          id: 'cmt_001',
          taskId: taskId,
          userId: 'mem_001',
          userName: 'Dr. Mohamed',
          text: 'Please make sure to follow the coding standards.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        CommentModel(
          id: 'cmt_002',
          taskId: taskId,
          userId: 'mem_002',
          userName: 'Eng. Alaa',
          text: 'Great progress! Let me know if you need help.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
}