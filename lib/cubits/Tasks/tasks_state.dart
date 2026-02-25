// lib/cubits/tasks/tasks_state.dart
import 'package:equatable/equatable.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';

// ✅ كل الـ States الممكنة لشاشة التاسكات
abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

// الحالة الأولى - لما الشاشة بتفتح
class TasksInitial extends TasksState {
  const TasksInitial();
}

// جاري التحميل
class TasksLoading extends TasksState {
  const TasksLoading();
}

// تحميل ناجح ✅
class TasksLoaded extends TasksState {
  final List<TaskModel> pendingTasks;
  final List<CompletedTaskModel> completedTasks;
  final List<TeamTaskModel> teamTasks;

  const TasksLoaded({
    required this.pendingTasks,
    required this.completedTasks,
    required this.teamTasks,
  });

  @override
  List<Object?> get props => [pendingTasks, completedTasks, teamTasks];

  // ✅ copyWith عشان نقدر نعدل جزء بدون ما نبني الكل من الأول
  TasksLoaded copyWith({
    List<TaskModel>? pendingTasks,
    List<CompletedTaskModel>? completedTasks,
    List<TeamTaskModel>? teamTasks,
  }) {
    return TasksLoaded(
      pendingTasks: pendingTasks ?? this.pendingTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      teamTasks: teamTasks ?? this.teamTasks,
    );
  }
}

// حصل error ❌
class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}

// جاري رفع الملفات (حالة خاصة بـ submit)
class TaskSubmitting extends TasksState {
  const TaskSubmitting();
}

// رفع الملفات نجح ✅
class TaskSubmitted extends TasksState {
  final String taskId;
  const TaskSubmitted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

// رفع الملفات فشل ❌
class TaskSubmitError extends TasksState {
  final String message;
  const TaskSubmitError(this.message);

  @override
  List<Object?> get props => [message];
}