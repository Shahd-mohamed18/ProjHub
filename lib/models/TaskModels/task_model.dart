// lib/models/TaskModels/task_model.dart
import 'package:intl/intl.dart';

class TaskModel {
  final String id;
  final String title;
  final String from;
  final DateTime dueDate;
  final String? description;
  final String teamId;
  final bool isCompleted;
  final List<String> assignedTo;
  final String supervisorId;
  final List<Map<String, String>>? supervisorAttachments;
  final List<Map<String, String>>? studentAttachments;

  const TaskModel({
    required this.id,
    required this.title,
    required this.from,
    required this.dueDate,
    required this.teamId,
    required this.supervisorId,
    this.assignedTo = const [],
    this.description,
    this.supervisorAttachments,
    this.studentAttachments,
    this.isCompleted = false,
  });

  String get formattedDueDate => DateFormat('MMM dd, yyyy').format(dueDate);

  bool isAssignedTo(String userId) => assignedTo.contains(userId);

  TaskModel copyWith({
    String? id,
    String? title,
    String? from,
    DateTime? dueDate,
    String? teamId,
    String? supervisorId,
    List<String>? assignedTo,
    String? description,
    List<Map<String, String>>? supervisorAttachments,
    List<Map<String, String>>? studentAttachments,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      from: from ?? this.from,
      dueDate: dueDate ?? this.dueDate,
      teamId: teamId ?? this.teamId,
      supervisorId: supervisorId ?? this.supervisorId,
      assignedTo: assignedTo ?? this.assignedTo,
      description: description ?? this.description,
      supervisorAttachments: supervisorAttachments ?? this.supervisorAttachments,
      studentAttachments: studentAttachments ?? this.studentAttachments,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      from: json['from'],
      dueDate: DateTime.parse(json['dueDate']),
      teamId: json['teamId'] ?? '',
      supervisorId: json['supervisorId'] ?? '',
      assignedTo: List<String>.from(json['assignedTo'] ?? []),
      description: json['description'],
      supervisorAttachments: (json['supervisorAttachments'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(),
      studentAttachments: (json['studentAttachments'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'from': from,
        'dueDate': dueDate.toIso8601String(),
        'teamId': teamId,
        'supervisorId': supervisorId,
        'assignedTo': assignedTo,
        'description': description,
        'supervisorAttachments': supervisorAttachments,
        'studentAttachments': studentAttachments,
        'isCompleted': isCompleted,
      };

  // ✅ Mock tasks - IDs تتطابق مع TeamsCubit members IDs
  static final List<TaskModel> _tasks = [
    TaskModel(
      id: 'task_001',
      title: 'UI Design Review',
      from: 'Supervisor',
      dueDate: DateTime(2025, 8, 20),
      teamId: '1',
      supervisorId: 'supervisor_1',
      assignedTo: ['m1', 'm2'],
      description: 'Review the current UI designs and provide feedback.',
      supervisorAttachments: [
        {'name': 'design_guidelines.pdf', 'type': 'pdf'},
      ],
      studentAttachments: [],
      isCompleted: false,
    ),
    TaskModel(
      id: 'task_002',
      title: 'Backend Integration',
      from: 'Supervisor',
      dueDate: DateTime(2025, 8, 25),
      teamId: '1',
      supervisorId: 'supervisor_1',
      assignedTo: ['m3', 'm4'],
      description: 'Integrate Flutter app with .NET backend APIs.',
      supervisorAttachments: [],
      studentAttachments: [],
      isCompleted: false,
    ),
    TaskModel(
      id: 'task_003',
      title: 'Project Documentation',
      from: 'Supervisor',
      dueDate: DateTime(2025, 9, 1),
      teamId: '2',
      supervisorId: 'supervisor_1',
      assignedTo: ['m3', 'm4', 'm6'],
      description: 'Write technical documentation for all modules.',
      supervisorAttachments: [],
      studentAttachments: [
        {'name': 'docs_v1.pdf', 'type': 'pdf'},
      ],
      isCompleted: true,
    ),
  ];

  static List<TaskModel> get mockTasks => List.from(_tasks);

  // ✅ submitTask بيحدث الـ task في الـ list
  static void markAsCompleted(String taskId, List<String> filePaths) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: true,
        studentAttachments: filePaths
            .map((p) => {'name': p.split('/').last, 'type': p.split('.').last})
            .toList(),
      );
    }
  }
}