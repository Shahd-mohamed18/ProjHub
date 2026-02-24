// lib/models/completed_task_model.dart
class CompletedTaskModel {
  final String id;
  final String title;
  final DateTime completedDate;
  final String status;
  final bool hasFeedback;

  CompletedTaskModel({
    required this.id,
    required this.title,
    required this.completedDate,
    required this.status,
    this.hasFeedback = true, // الفيجما بيظهر View Feedback لجميع المهام المنجزة
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