// lib/cubits/supervisor/supervisor_task_cubit.dart
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

  String? _cachedSupervisorId;

  SupervisorTaskCubit(this._taskRepository, this._teamsCubit)
      : super(SupervisorTaskInitial());

  // ── load ──────────────────────────────────────────────────────

  Future<void> loadSupervisorData(String supervisorId) async {
    _cachedSupervisorId = supervisorId;
    emit(SupervisorTaskLoading());
    try {
      final teamsState = _teamsCubit.state;
      final teams =
          teamsState is TeamsLoaded ? teamsState.teams : <TeamModel>[];

      final tasks = await _taskRepository.getTasksBySupervisor(supervisorId);

      emit(SupervisorTasksLoaded(
        teams: teams,
        allTasks: tasks,
        selectedTeamId: null,
      ));
    } catch (e) {
      emit(SupervisorTaskError('Failed to load data: $e'));
    }
  }

  // ── filter ────────────────────────────────────────────────────

  void filterByTeam(String? teamId) {
    if (state is SupervisorTasksLoaded) {
      final cur = state as SupervisorTasksLoaded;
      emit(teamId == null
          ? cur.clearTeamFilter()
          : cur.copyWith(selectedTeamId: teamId));
    }
  }

  // ── create ────────────────────────────────────────────────────

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedTo,
    String? attachment,
    List<Map<String, String>> supervisorAttachments = const [],
    required String teamId,
    String supervisorName = 'Supervisor',
  }) async {
    final previousState = state;
    emit(SupervisorTaskLoading());
    try {
      if (_taskRepository is ApiTaskRepository) {
        final api = _taskRepository as ApiTaskRepository;
        await api.createTask(
          title: title,
          description: description,
          dueDate: dueDate,
          teamId: int.tryParse(teamId) ?? 0,
          assignedTo: assignedTo,
          supervisorName: supervisorName,
          supervisorAttachments: supervisorAttachments,
        );
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }

      emit(SupervisorTaskSuccess());

      if (_cachedSupervisorId != null) {
        await loadSupervisorData(_cachedSupervisorId!);
      }
    } catch (e) {
      String msg = 'Failed to create task: $e';
      if (e is ApiException) {
        if (e.statusCode == 403) {
          msg = 'You are not the supervisor of this team. '
              'Please delete this team and recreate it to fix the issue.';
        } else if (e.statusCode == 404) {
          msg = 'Team not found. Please reload and try again.';
        } else {
          msg = 'Server error (${e.statusCode}). Please try again.';
        }
      }
      emit(SupervisorTaskError(msg));
      if (previousState is SupervisorTasksLoaded) emit(previousState);
    }
  }

  // ── delete task ───────────────────────────────────────────────

  /// DELETE /api/Tasks/{id}?supervisorId=
  Future<void> deleteTask(String taskId) async {
    final previousState = state;
    try {
      if (_taskRepository is ApiTaskRepository) {
        final api = _taskRepository as ApiTaskRepository;
        final ok = await api.deleteTask(taskId);
        if (!ok) {
          emit(SupervisorTaskError('Failed to delete task'));
          if (previousState is SupervisorTasksLoaded) emit(previousState);
          return;
        }
      }

      // Remove task from local state immediately
      if (previousState is SupervisorTasksLoaded) {
        final updated = previousState.allTasks
            .where((t) => t.id != taskId)
            .toList();
        emit(previousState.copyWith(allTasks: updated));
      }

      emit(SupervisorTaskSuccess());

      // Reload to stay in sync with the backend
      if (_cachedSupervisorId != null) {
        await loadSupervisorData(_cachedSupervisorId!);
      }
    } catch (e) {
      emit(SupervisorTaskError('Failed to delete task: $e'));
      if (previousState is SupervisorTasksLoaded) emit(previousState);
    }
  }

  // ── feedback ──────────────────────────────────────────────────

  Future<void> giveFeedback({
    required String taskId,
    required String message,
    required String from,
    List<Map<String, String>> attachments = const [],
  }) async {
    try {
      if (_taskRepository is ApiTaskRepository) {
        final api = _taskRepository as ApiTaskRepository;
        final ok = await api.addFeedback(
          taskId: taskId,
          message: message,
          from: from,
          attachments: attachments,
        );
        if (!ok) {
          emit(SupervisorTaskError('Failed to submit feedback'));
          return;
        }
      }
      emit(SupervisorTaskSuccess());
    } catch (e) {
      emit(SupervisorTaskError('Failed to submit feedback: $e'));
    }
  }
}