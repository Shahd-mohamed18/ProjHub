// lib/models/feedback_model.dart
class FeedbackModel {
  final String id;
  final String taskId;
  final String from; // Supervisor أو Assistant
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static List<FeedbackModel> mockFeedbacks = [
    FeedbackModel(
      id: '1',
      taskId: '1',
      from: 'Supervisor',
      message: 'Good work on project structure. setup is perfect.',
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

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      taskId: json['taskId'],
      from: json['from'],
      message: json['message'],
      date: DateTime.parse(json['date']),
      attachments: (json['attachments'] as List)
          .map((a) => AttachmentModel.fromJson(a))
          .toList(),
    );
  }
}

class AttachmentModel {
  final String name;
  final String type;

  AttachmentModel({required this.name, required this.type});

  Map<String, dynamic> toJson() => {'name': name, 'type': type};

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(name: json['name'], type: json['type']);
  }
}