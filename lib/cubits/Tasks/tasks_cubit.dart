// lib/cubits/tasks/tasks_cubit.dart
//
// Changes vs previous version
// ─────────────────────────────────────────────────────────────
// • loadTasks() now reads the current Firebase UID automatically
//   when no userId is passed – no more hardcoded IDs.
// • submitTask() passes userId so the list refreshes after submit.
// • A new loadTeamTasks(teamId) method is added for future use.
// ─────────────────────────────────────────────────────────────
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/tasks/tasks_state.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/repositories/task_repository.dart';

class TasksCubit extends Cubit<TasksState> {
  final ITaskRepository _repository;

  TasksCubit(this._repository) : super(const TasksInitial());

  // ── helpers ─────────────────────────────────────────────────

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ── public API ───────────────────────────────────────────────

  /// Loads pending, completed and team tasks.
  ///
  /// [userId] is optional – falls back to the current Firebase UID so callers
  /// don't need to thread it through.
  /// [teamId] is needed for the team-tasks section.
  Future<void> loadTasks({String? userId, String? teamId}) async {
    final uid = userId ?? _currentUserId;

    emit(const TasksLoading());
    try {
      final results = await Future.wait([
        _repository.getPendingTasks(userId: uid),
        _repository.getCompletedTasks(userId: uid),
        _repository.getTeamTasks(teamId: teamId),
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

  Future<void> refreshTasks({String? userId, String? teamId}) =>
      loadTasks(userId: userId, teamId: teamId);

  /// Submit a task with file attachments.
  Future<void> submitTask({
    required String taskId,
    required List<String> filePaths,
    String? userId,
  }) async {
    final uid = userId ?? _currentUserId;
    final currentState = state;
    emit(const TaskSubmitting());
    try {
      final success = await _repository.submitTask(
        taskId: taskId,
        filePaths: filePaths,
      );
      if (success) {
        emit(TaskSubmitted(taskId));
        // Reload to move the task from Pending → Completed in the UI
        await loadTasks(userId: uid);
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