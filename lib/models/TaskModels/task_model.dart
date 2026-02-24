// lib/models/task_model.dart

enum TaskStatus { pending, submitted, approved, rejected }

class TaskModel {
  final String id;
  final String title;
  final String from;
  final DateTime dueDate;
  bool isCompleted;
  final String? description;
  final List<Map<String, String>>? myAttachments;
  final TaskStatus status; // ✅ جديد

  TaskModel({
    required this.id,
    required this.title,
    required this.from,
    required this.dueDate,
    this.isCompleted = false,
    this.description,
    this.myAttachments,
    this.status = TaskStatus.pending, // ✅ default قيمته pending
  });

  String get formattedDueDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dueDate.month - 1]} ${dueDate.day}, ${dueDate.year}';
  }

  // ✅ helper بيرجع نص الـ status
  String get statusLabel {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.submitted:
        return 'Submitted';
      case TaskStatus.approved:
        return 'Approved';
      case TaskStatus.rejected:
        return 'Rejected';
    }
  }

  // ✅ helper بيرجع لون الـ status
  // استخدامه: Color statusColor = task.statusColor;
  int get statusColorValue {
    switch (status) {
      case TaskStatus.pending:
        return 0xFFFFA500; // Orange
      case TaskStatus.submitted:
        return 0xFF2196F3; // Blue
      case TaskStatus.approved:
        return 0xFF4CAF50; // Green
      case TaskStatus.rejected:
        return 0xFFF44336; // Red
    }
  }

  static List<TaskModel> mockTasks = [
    TaskModel(
      id: '1',
      title: 'Complete Project Documentation',
      from: 'Supervisor',
      dueDate: DateTime(2026, 2, 3),
      description:
          'Design the homepage for e-commerce platform with product listings and navigation.',
      status: TaskStatus.pending, // ✅
      myAttachments: [
        {'name': 'Wireframe.fig', 'type': 'FIG'},
        {'name': 'Documentation.pdf', 'type': 'PDF'},
      ],
    ),
    TaskModel(
      id: '2',
      title: 'Prototyping',
      from: 'Supervisor',
      dueDate: DateTime(2026, 2, 2),
      description: 'Create interactive prototype for the new feature.',
      status: TaskStatus.submitted, // ✅
      myAttachments: [],
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'from': from,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'description': description,
      'myAttachments': myAttachments,
      'status': status.name, // ✅ بيبعت "pending" / "submitted" / إلخ
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      from: json['from'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      description: json['description'],
      myAttachments: json['myAttachments'] != null
          ? List<Map<String, String>>.from(
              (json['myAttachments'] as List).map(
                (e) => Map<String, String>.from(e),
              ),
            )
          : null,
      // ✅ بيحول الـ string الجاي من الـ backend لـ enum
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
    );
  }
}