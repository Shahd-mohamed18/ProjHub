// lib/models/task_model.dart
import 'package:intl/intl.dart';

class TaskModel {
  final String id;
  final String title;
  final String from; // 'Supervisor' | 'Assistant'
  final DateTime dueDate;
  final String? description;
  final List<Map<String, String>>? myAttachments;

  const TaskModel({
    required this.id,
    required this.title,
    required this.from,
    required this.dueDate,
    this.description,
    this.myAttachments,
  });

  String get formattedDueDate => DateFormat('MMM dd, yyyy').format(dueDate);

  // ✅ جاهز للـ API
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      from: json['from'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      description: json['description'] as String?,
      myAttachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'from': from,
        'due_date': dueDate.toIso8601String(),
        'description': description,
        'attachments': myAttachments,
      };

  // ✅ Mock Data مؤقتة - هتتشال لما الـ API يجهز
  static List<TaskModel> get mockTasks => [
        TaskModel(
          id: 'task_001',
          title: 'UI Design Review',
          from: 'Supervisor',
          dueDate: DateTime(2025, 8, 20),
          description:
              'Review the current UI designs and provide feedback on the color scheme, typography, and overall layout consistency.',
          myAttachments: [],
        ),
        TaskModel(
          id: 'task_002',
          title: 'Backend Integration',
          from: 'Assistant',
          dueDate: DateTime(2025, 8, 25),
          description:
              'Integrate the Flutter app with the .NET backend APIs for authentication and task management.',
          myAttachments: [],
        ),
        TaskModel(
          id: 'task_003',
          title: 'Testing & Documentation',
          from: 'Supervisor',
          dueDate: DateTime(2025, 9, 1),
          description: 'Write unit tests and document all public APIs.',
          myAttachments: [],
        ),
      ];
}