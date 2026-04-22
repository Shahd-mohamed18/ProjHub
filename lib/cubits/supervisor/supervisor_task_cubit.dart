// lib/cubits/supervisor/supervisor_task_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/repositories/task_repository.dart';

part 'supervisor_task_state.dart';

class SupervisorTaskCubit extends Cubit<SupervisorTaskState> {
  final ITaskRepository _taskRepository;
  final TeamsCubit _teamsCubit; // ✅ بياخد teams من TeamsCubit مباشرة

  SupervisorTaskCubit(this._taskRepository, this._teamsCubit)
      : super(SupervisorTaskInitial());

  Future<void> loadSupervisorData(String supervisorId) async {
    emit(SupervisorTaskLoading());
    try {
      // ✅ teams من TeamsCubit - مفيش call تاني
      final teamsState = _teamsCubit.state;
      final teams = teamsState is TeamsLoaded
          ? teamsState.teams
          : <TeamModel>[];

      final tasks =
          await _taskRepository.getTasksBySupervisor(supervisorId);

      emit(SupervisorTasksLoaded(
        teams: teams,
        allTasks: tasks,
        selectedTeamId: null,
      ));
    } catch (e) {
      emit(SupervisorTaskError('Failed to load data: ${e.toString()}'));
    }
  }

  void filterByTeam(String? teamId) {
    if (state is SupervisorTasksLoaded) {
      final current = state as SupervisorTasksLoaded;
      if (teamId == null) {
        emit(current.clearTeamFilter());
      } else {
        emit(current.copyWith(selectedTeamId: teamId));
      }
    }
  }

  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedTo,
    String? attachment,
    required String teamId,
  }) async {
    final currentState = state;
    emit(SupervisorTaskLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(SupervisorTaskSuccess());
    } catch (e) {
      emit(SupervisorTaskError('Failed to create task: $e'));
      if (currentState is SupervisorTasksLoaded) {
        emit(currentState);
      }
    }
  }
}