// lib/cubits/tasks/tasks_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/tasks/tasks_state.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/repositories/task_repository.dart';

class TasksCubit extends Cubit<TasksState> {
  final ITaskRepository _repository;

  TasksCubit(this._repository) : super(const TasksInitial());

  Future<void> loadTasks() async {
    emit(const TasksLoading());
    try {
      final results = await Future.wait([
        _repository.getPendingTasks(),
        _repository.getCompletedTasks(),
        _repository.getTeamTasks(),
      ]);

      emit(TasksLoaded(
        pendingTasks: results[0] as List<TaskModel>,
        completedTasks: results[1] as List<CompletedTaskModel>,
        teamTasks: results[2] as List<TeamTaskModel>,
      ));
    } catch (e) {
      emit(TasksError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> refreshTasks() => loadTasks();

  Future<void> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    final currentState = state;
    emit(const TaskSubmitting());
    try {
      final success = await _repository.submitTask(
        taskId: taskId,
        filePaths: filePaths,
      );

      if (success) {
        emit(TaskSubmitted(taskId));
        await loadTasks();
      } else {
        emit(const TaskSubmitError('Submission failed. Please try again.'));
        if (currentState is TasksLoaded) emit(currentState);
      }
    } catch (e) {
      emit(TaskSubmitError('Error: ${e.toString()}'));
      if (currentState is TasksLoaded) emit(currentState);
    }
  }
}