// lib/models/TaskModels/feedback_model.dart
class FeedbackModel {
  final String id;
  final String taskId;
  final String from;
  final String message;
  final DateTime date;
  final List<AttachmentModel> attachments;

  FeedbackModel({
    required this.id,
    required this.taskId,
    required this.from,
    required this.message,
    required this.date,
    required this.attachments,
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

    // Parse attachments safely
    List<AttachmentModel> attachments = [];
    final rawAttachments =
        json['attachments'] ?? json['feedbackAttachments'];
    if (rawAttachments is List) {
      attachments = rawAttachments
          .map((a) => AttachmentModel.fromJson(a as Map<String, dynamic>))
          .toList();
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
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'from': from,
      'message': message,
      'date': date.toIso8601String(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  static List<FeedbackModel> mockFeedbacks = [
    FeedbackModel(
      id: '1',
      taskId: '1',
      from: 'Supervisor',
      message: 'Good work on project structure. Setup is perfect.',
      date: DateTime(2026, 1, 15),
      attachments: [
        AttachmentModel(name: 'Wireframe.fig', type: 'FIG'),
        AttachmentModel(name: 'Documentation', type: 'PDF'),
      ],
    ),
    FeedbackModel(
      id: '2',
      taskId: '1',
      from: 'Assistant',
      message: 'Excellent documentation.',
      date: DateTime(2026, 2, 20),
      attachments: [],
    ),
  ];
}

class AttachmentModel {
  final String name;
  final String type;

  AttachmentModel({required this.name, required this.type});

  Map<String, dynamic> toJson() => {'name': name, 'type': type};

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      name: (json['name'] ?? json['fileName'] ?? '').toString(),
      type: (json['type'] ?? json['fileType'] ?? 'file').toString(),
    );
  }
}