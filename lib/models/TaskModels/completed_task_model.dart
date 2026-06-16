// lib/models/completed_task_model.dart
import 'package:onboard/models/TaskModels/task_model.dart';

class CompletedTaskModel {
  final String id;
  final String title;
  final DateTime completedDate;
  final String status;
  final bool hasFeedback;
  // Full task model so student can re-open TaskDetailsScreen after submit
  final TaskModel? taskModel;

  CompletedTaskModel({
    required this.id,
    required this.title,
    required this.completedDate,
    required this.status,
    this.hasFeedback = true,
    this.taskModel,
  });

  String get formattedCompletedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[completedDate.month - 1]} ${completedDate.day}';
  }

  static List<CompletedTaskModel> mockCompletedTasks = [
    CompletedTaskModel(
      id: '1',
      title: 'Prototyping',
      completedDate: DateTime(2026, 2, 10),
      status: 'Approved',
    ),
    CompletedTaskModel(
      id: '2',
      title: 'Database Schema',
      completedDate: DateTime(2026, 3, 12),
      status: 'Approved',
    ),
  ];
}