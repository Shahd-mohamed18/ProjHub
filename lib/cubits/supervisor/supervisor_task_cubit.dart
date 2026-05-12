// lib/cubits/supervisor/supervisor_task_cubit.dart
//
// Changes vs the previous version
// ─────────────────────────────────────────────────────────────
// • createTask() now calls _taskRepository.createTask() (real API)
//   and only falls back to a local optimistic update on success.
// • After successful creation it reloads the full task list so the
//   AllTasksScreen stays in sync.
// • Error handling is more granular.
// ─────────────────────────────────────────────────────────────
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/repositories/api_task_repository.dart';
import 'package:onboard/repositories/task_repository.dart';

part 'supervisor_task_state.dart';

class SupervisorTaskCubit extends Cubit<SupervisorTaskState> {
  final ITaskRepository _taskRepository;
  final TeamsCubit _teamsCubit;

  // Cache the supervisorId so we can reload after createTask
  String? _cachedSupervisorId;

  SupervisorTaskCubit(this._taskRepository, this._teamsCubit)
      : super(SupervisorTaskInitial());

  // ── load ────────────────────────────────────────────────────

  Future<void> loadSupervisorData(String supervisorId) async {
    _cachedSupervisorId = supervisorId;
    emit(SupervisorTaskLoading());
    try {
      final teamsState = _teamsCubit.state;
      final teams = teamsState is TeamsLoaded ? teamsState.teams : <TeamModel>[];

      final tasks = await _taskRepository.getTasksBySupervisor(supervisorId);

      emit(SupervisorTasksLoaded(
        teams: teams,
        allTasks: tasks,
        selectedTeamId: null,
      ));
    } catch (e) {
      emit(SupervisorTaskError('Failed to load data: ${e.toString()}'));
    }
  }

  // ── filter ──────────────────────────────────────────────────

  void filterByTeam(String? teamId) {
    if (state is SupervisorTasksLoaded) {
      final current = state as SupervisorTasksLoaded;
      emit(teamId == null ? current.clearTeamFilter() : current.copyWith(selectedTeamId: teamId));
    }
  }

  // ── create ──────────────────────────────────────────────────

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedTo,
    String? attachment,
    required String teamId, // String ID from TeamModel
  }) async {
    final previousState = state;
    emit(SupervisorTaskLoading());

    try {
      // ApiTaskRepository exposes the real createTask method.
      // ITaskRepository does not, so we cast if available.
      if (_taskRepository is ApiTaskRepository) {
        final api = _taskRepository as ApiTaskRepository;

        final attachments = attachment != null
            ? [{'name': attachment, 'type': attachment.split('.').last}]
            : <Map<String, String>>[];

        await api.createTask(
          title: title,
          description: description,
          dueDate: dueDate,
          teamId: int.tryParse(teamId) ?? 0,
          assignedTo: assignedTo,
          attachments: attachments,
        );
      } else {
        // MockTaskRepository path – just simulate a delay
        await Future.delayed(const Duration(seconds: 1));
      }

      emit(SupervisorTaskSuccess());

      // Reload so AllTasksScreen sees the new task immediately
      if (_cachedSupervisorId != null) {
        await loadSupervisorData(_cachedSupervisorId!);
      }
    } catch (e) {
      emit(SupervisorTaskError('Failed to create task: $e'));
      // Restore previous state so the screen doesn't stay blank
      if (previousState is SupervisorTasksLoaded) {
        emit(previousState);
      }
    }
  }

  // ── give feedback ────────────────────────────────────────────

  Future<void> giveFeedback({
    required String taskId,
    required String message,
    required String from,
    List<Map<String, String>> attachments = const [],
  }) async {
    try {
      if (_taskRepository is ApiTaskRepository) {
        final api = _taskRepository as ApiTaskRepository;
        await api.addFeedback(
          taskId: taskId,
          message: message,
          from: from,
          attachments: attachments,
        );
      }
      emit(SupervisorTaskSuccess());
    } catch (e) {
      emit(SupervisorTaskError('Failed to submit feedback: $e'));
    }
  }
}