// test/cubits/tasks_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboard/cubits/tasks/tasks_cubit.dart';
import 'package:onboard/cubits/tasks/tasks_state.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/repositories/task_repository.dart';

// ✅ Mock Repository للـ Testing
class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late MockTaskRepository mockRepo;
  late TasksCubit cubit;

  // ✅ Sample data للـ Tests
  final samplePending = TaskModel.mockTasks;
  final sampleCompleted = CompletedTaskModel.mockCompletedTasks;
  final sampleTeam = TeamTaskModel.mockTeamTasks;

  setUp(() {
    mockRepo = MockTaskRepository();
    cubit = TasksCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  group('TasksCubit -', () {
    // ─────────────────────────────────────────────
    // loadTasks Tests
    // ─────────────────────────────────────────────
    group('loadTasks', () {
      blocTest<TasksCubit, TasksState>(
        '✅ ينجح ويرجع TasksLoaded لما الـ Repository يرجع بيانات',
        build: () {
          when(() => mockRepo.getPendingTasks())
              .thenAnswer((_) async => samplePending);
          when(() => mockRepo.getCompletedTasks())
              .thenAnswer((_) async => sampleCompleted);
          when(() => mockRepo.getTeamTasks())
              .thenAnswer((_) async => sampleTeam);
          return cubit;
        },
        act: (c) => c.loadTasks(),
        expect: () => [
          const TasksLoading(),
          TasksLoaded(
            pendingTasks: samplePending,
            completedTasks: sampleCompleted,
            teamTasks: sampleTeam,
          ),
        ],
      );

      blocTest<TasksCubit, TasksState>(
        '❌ يرجع TasksError لما يحصل Exception',
        build: () {
          when(() => mockRepo.getPendingTasks())
              .thenThrow(Exception('Network Error'));
          when(() => mockRepo.getCompletedTasks())
              .thenAnswer((_) async => []);
          when(() => mockRepo.getTeamTasks())
              .thenAnswer((_) async => []);
          return cubit;
        },
        act: (c) => c.loadTasks(),
        expect: () => [
          const TasksLoading(),
          isA<TasksError>(),
        ],
      );

      blocTest<TasksCubit, TasksState>(
        '✅ يرجع TasksLoaded بـ empty lists لو مفيش بيانات',
        build: () {
          when(() => mockRepo.getPendingTasks()).thenAnswer((_) async => []);
          when(() => mockRepo.getCompletedTasks()).thenAnswer((_) async => []);
          when(() => mockRepo.getTeamTasks()).thenAnswer((_) async => []);
          return cubit;
        },
        act: (c) => c.loadTasks(),
        expect: () => [
          const TasksLoading(),
          const TasksLoaded(
            pendingTasks: [],
            completedTasks: [],
            teamTasks: [],
          ),
        ],
      );
    });

    // ─────────────────────────────────────────────
    // submitTask Tests
    // ─────────────────────────────────────────────
    group('submitTask', () {
      blocTest<TasksCubit, TasksState>(
        '✅ ينجح الـ Submit ويرجع TaskSubmitted ثم يعمل loadTasks',
        build: () {
          when(() => mockRepo.submitTask(
                taskId: any(named: 'taskId'),
                filePaths: any(named: 'filePaths'),
              )).thenAnswer((_) async => true);
          when(() => mockRepo.getPendingTasks())
              .thenAnswer((_) async => samplePending);
          when(() => mockRepo.getCompletedTasks())
              .thenAnswer((_) async => sampleCompleted);
          when(() => mockRepo.getTeamTasks())
              .thenAnswer((_) async => sampleTeam);
          return cubit;
        },
        act: (c) => c.submitTask(
          taskId: 'task_001',
          filePaths: ['/path/to/file.pdf'],
        ),
        expect: () => [
          const TaskSubmitting(),
          const TaskSubmitted('task_001'),
          const TasksLoading(),
          isA<TasksLoaded>(),
        ],
      );

      blocTest<TasksCubit, TasksState>(
        '❌ يرجع TaskSubmitError لما الـ Repository يرجع false',
        build: () {
          when(() => mockRepo.submitTask(
                taskId: any(named: 'taskId'),
                filePaths: any(named: 'filePaths'),
              )).thenAnswer((_) async => false);
          return cubit;
        },
        act: (c) => c.submitTask(
          taskId: 'task_001',
          filePaths: ['/path/to/file.pdf'],
        ),
        expect: () => [
          const TaskSubmitting(),
          isA<TaskSubmitError>(),
        ],
      );
    });

    // ─────────────────────────────────────────────
    // Initial State Test
    // ─────────────────────────────────────────────
    test('✅ الـ initial state هي TasksInitial', () {
      expect(cubit.state, const TasksInitial());
    });
  });
}