// lib/models/TaskModels/feedback_model.dart
class FeedbackModel {
  final String id;
  final String taskId;
  final String from;
  final String message;
  final DateTime date;

  FeedbackModel({
    required this.id,
    required this.taskId,
    required this.from,
    required this.message,
    required this.date,
  });

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ✅ Safe fromJson — handles int ids, missing fields, null dates
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    // Parse date safely
    DateTime parsedDate = DateTime.now();
    final rawDate = json['date'] ??
        json['createdAt'] ??
        json['created_at'] ??
        json['feedbackDate'];
    if (rawDate != null) {
      try {
        String s = rawDate.toString();
        if (!s.endsWith('Z') && !s.contains('+') && !s.contains('-', 10)) {
          s += 'Z';
        }
        parsedDate = DateTime.parse(s).toLocal();
      } catch (_) {}
    }

    return FeedbackModel(
      id: (json['id'] ?? json['feedbackId'] ?? '').toString(),
      taskId: (json['taskId'] ?? json['task_id'] ?? '').toString(),
      from: (json['from'] ??
              json['senderName'] ??
              json['supervisorName'] ??
              'Supervisor')
          .toString(),
      message: (json['message'] ??
              json['content'] ??
              json['text'] ??
              '')
          .toString(),
      date: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'from': from,
      'message': message,
      'date': date.toIso8601String(),
    };
  }

  static List<FeedbackModel> mockFeedbacks = [
    FeedbackModel(
      id: '1',
      taskId: '1',
      from: 'Supervisor',
      message: 'Good work on project structure. Setup is perfect.',
      date: DateTime(2026, 1, 15),
    ),
    FeedbackModel(
      id: '2',
      taskId: '1',
      from: 'Assistant',
      message: 'Excellent documentation.',
      date: DateTime(2026, 2, 20),
    ),
  ];
}