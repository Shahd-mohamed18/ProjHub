// lib/models/team_task_model.dart
class TeamTaskModel {
  final String id;
  final String title;
  final String assignedTo;
  final DateTime dueDate;

  TeamTaskModel({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
  });

  String get formattedDueDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dueDate.month - 1]} ${dueDate.day}';
  }

  static List<TeamTaskModel> mockTeamTasks = [
    TeamTaskModel(id: '1', title: 'Mapping', assignedTo: 'Asmaa', dueDate: DateTime(2026, 3, 25)),
    TeamTaskModel(id: '2', title: 'Chat Bot', assignedTo: 'Aya', dueDate: DateTime(2026, 3, 30)),
    TeamTaskModel(id: '3', title: 'Final Documentation', assignedTo: 'Mohamed', dueDate: DateTime(2026, 5, 5)),
  ];
}