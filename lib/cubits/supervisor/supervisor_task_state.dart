// lib/cubits/supervisor/supervisor_task_state.dart
part of 'supervisor_task_cubit.dart';

abstract class SupervisorTaskState {}

class SupervisorTaskInitial extends SupervisorTaskState {}

class SupervisorTaskLoading extends SupervisorTaskState {}

class SupervisorTasksLoaded extends SupervisorTaskState {
  final List<TeamModel> teams; // ✅ TeamModel من TeamModels/team_model.dart
  final List<TaskModel> allTasks;
  final String? selectedTeamId;

  SupervisorTasksLoaded({
    required this.teams,
    required this.allTasks,
    this.selectedTeamId,
  });

  List<TaskModel> get filteredTasks {
    if (selectedTeamId == null) return allTasks;
    return allTasks.where((t) => t.teamId == selectedTeamId).toList();
  }

  List<TaskModel> get inProgressTasks =>
      filteredTasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      filteredTasks.where((t) => t.isCompleted).toList();

  SupervisorTasksLoaded copyWith({
    List<TeamModel>? teams,
    List<TaskModel>? allTasks,
    String? selectedTeamId,
  }) {
    return SupervisorTasksLoaded(
      teams: teams ?? this.teams,
      allTasks: allTasks ?? this.allTasks,
      selectedTeamId: selectedTeamId ?? this.selectedTeamId,
    );
  }

  SupervisorTasksLoaded clearTeamFilter() {
    return SupervisorTasksLoaded(
      teams: teams,
      allTasks: allTasks,
      selectedTeamId: null,
    );
  }
}

class SupervisorTaskSuccess extends SupervisorTaskState {}

class SupervisorTaskError extends SupervisorTaskState {
  final String message;
  SupervisorTaskError(this.message);
}