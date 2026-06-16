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
  /// Name of the student who submitted this task (null until submitted).
  /// Populated from the backend response if available.
  final String? submittedByName;

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
    this.submittedByName,
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
    String? submittedByName,
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
      supervisorAttachments:
          supervisorAttachments ?? this.supervisorAttachments,
      studentAttachments: studentAttachments ?? this.studentAttachments,
      isCompleted: isCompleted ?? this.isCompleted,
      submittedByName: submittedByName ?? this.submittedByName,
    );
  }

  // ✅ FIXED: all fields are null-safe — backend often omits fields
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Parse dueDate safely
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(
          (json['dueDate'] ?? json['due_date'] ?? '').toString());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return TaskModel(
      id: (json['id'] ?? json['taskId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      // 'from' is often null from backend — fall back gracefully
      from: (json['from'] ??
              json['supervisorName'] ??
              json['supervisorFullName'] ??
              json['createdByName'] ??
              json['assignedByName'] ??
              json['submittedByName'] ??
              json['studentName'] ??
              json['createdBy'] ??
              json['userName'] ??
              'Supervisor')
          .toString(),
      dueDate: parsedDate,
      teamId: (json['teamId'] ?? json['team_id'] ?? '').toString(),
      supervisorId:
          (json['supervisorId'] ?? json['createdById'] ?? '').toString(),
      // assignedTo is often null when task is for all members
      assignedTo: json['assignedTo'] != null
          ? List<String>.from(
              (json['assignedTo'] as List).map((e) => e.toString()))
          : const [],
      // description may be null — show nothing, not "no description"
      description: json['description']?.toString(),
      supervisorAttachments: _parseAttachList(json['supervisorAttachments']),
      studentAttachments: _parseAttachList(json['studentAttachments']),
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      submittedByName: (json['submittedByName'] ??
              json['studentName'] ??
              json['submittedBy'] ??
              json['submitterName'])
          ?.toString(),
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
        'submittedByName': submittedByName,
      };

  // ✅ Mock tasks
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

  /// Safely parses an attachment list regardless of whether it came from
  /// raw JSON (List of Map<String,dynamic>) or already-normed data
  /// (List of Map<String,String>). Never throws.
  static List<Map<String, String>>? _parseAttachList(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;
    if (raw.isEmpty) return [];
    try {
      return raw.map<Map<String, String>>((e) {
        if (e is Map<String, String>) return e;
        final m = e as Map;
        return {
          'name': (m['name'] ?? m['fileName'] ?? '').toString(),
          'type': (m['type'] ?? m['fileType'] ?? 'file').toString(),
        };
      }).toList();
    } catch (_) {
      return null;
    }
  }

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