// lib/cubits/tasks/tasks_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/tasks/tasks_state.dart';
import 'package:onboard/repositories/task_repository.dart';

class TasksCubit extends Cubit<TasksState> {
  final ITaskRepository _repository;

  // ✅ بنحط الـ Repository كـ dependency - سهل للـ Testing
  TasksCubit(this._repository) : super(const TasksInitial());

  // ✅ جيب كل التاسكات - بيتشغل لما الشاشة تفتح
  Future<void> loadTasks() async {
    emit(const TasksLoading());
    try {
      // ✅ بنجيب الـ 3 lists مع بعض بدل ما نستناهم واحدة ورا التانية
      final results = await Future.wait([
        _repository.getPendingTasks(),
        _repository.getCompletedTasks(),
        _repository.getTeamTasks(),
      ]);

      emit(TasksLoaded(
        pendingTasks: results[0] as dynamic,
        completedTasks: results[1] as dynamic,
        teamTasks: results[2] as dynamic,
      ));
    } catch (e) {
      emit(TasksError('Failed to load tasks: ${e.toString()}'));
    }
  }

  // ✅ Refresh - نفس loadTasks بس بنوضح الـ intent
  Future<void> refreshTasks() => loadTasks();

  // ✅ Submit Task - رفع الملفات
  Future<void> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    // نحفظ الـ state الحالي عشان نرجعله لو حصل error
    final currentState = state;

    emit(const TaskSubmitting());
    try {
      final success = await _repository.submitTask(
        taskId: taskId,
        filePaths: filePaths,
      );

      if (success) {
        emit(TaskSubmitted(taskId));
        // ✅ بعد الـ submit نعيد تحميل التاسكات عشان تتحول من Pending لـ Completed
        await loadTasks();
      } else {
        emit(const TaskSubmitError('Submission failed. Please try again.'));
        // نرجع للـ state السابق
        if (currentState is TasksLoaded) emit(currentState);
      }
    } catch (e) {
      emit(TaskSubmitError('Error: ${e.toString()}'));
      if (currentState is TasksLoaded) emit(currentState);
    }
  }
}