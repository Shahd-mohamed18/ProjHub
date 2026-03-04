// test/cubits/comments_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboard/cubits/comments/comments_cubit.dart';
import 'package:onboard/cubits/comments/comments_state.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';
import 'package:onboard/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late MockTaskRepository mockRepo;
  late CommentsCubit cubit;

  final sampleComments = CommentModel.mockCommentsForTask('task_001');

  final newComment = CommentModel(
    id: 'cmt_new',
    taskId: 'task_001',
    userId: 'user_me',
    userName: 'Me',
    text: 'This is a test comment',
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRepo = MockTaskRepository();
    cubit = CommentsCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  group('CommentsCubit -', () {
    group('loadComments', () {
      blocTest<CommentsCubit, CommentsState>(
        '✅ يرجع CommentsLoaded بالكومنتات',
        build: () {
          when(() => mockRepo.getCommentsForTask('task_001'))
              .thenAnswer((_) async => sampleComments);
          return cubit;
        },
        act: (c) => c.loadComments('task_001'),
        expect: () => [
          const CommentsLoading(),
          CommentsLoaded(comments: sampleComments),
        ],
      );

      blocTest<CommentsCubit, CommentsState>(
        '❌ يرجع CommentsError لما يحصل Exception',
        build: () {
          when(() => mockRepo.getCommentsForTask(any()))
              .thenThrow(Exception('Network Error'));
          return cubit;
        },
        act: (c) => c.loadComments('task_001'),
        expect: () => [
          const CommentsLoading(),
          isA<CommentsError>(),
        ],
      );
    });

    group('addComment', () {
      blocTest<CommentsCubit, CommentsState>(
        '✅ يضيف الكومنت للقايمة الحالية',
        build: () {
          when(() => mockRepo.addComment(
                taskId: any(named: 'taskId'),
                text: any(named: 'text'),
                userId: any(named: 'userId'),
                userName: any(named: 'userName'),
              )).thenAnswer((_) async => newComment);
          return cubit;
        },
        seed: () => CommentsLoaded(comments: sampleComments),
        act: (c) => c.addComment(
          taskId: 'task_001',
          text: 'This is a test comment',
          userId: 'user_me',
          userName: 'Me',
        ),
        expect: () => [
          CommentsLoaded(comments: sampleComments, isSending: true),
          CommentsLoaded(
            comments: [...sampleComments, newComment],
            isSending: false,
          ),
        ],
      );

      blocTest<CommentsCubit, CommentsState>(
        '⚠️ لو الـ state مش CommentsLoaded، ميعملش حاجة',
        build: () => cubit,
        act: (c) => c.addComment(
          taskId: 'task_001',
          text: 'test',
          userId: 'u1',
          userName: 'User',
        ),
        expect: () => [],
      );
    });

    test('✅ الـ initial state هي CommentsInitial', () {
      expect(cubit.state, const CommentsInitial());
    });
  });
}