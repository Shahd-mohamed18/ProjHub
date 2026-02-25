// lib/repositories/task_repository.dart
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';

// ✅ Abstract class
abstract class ITaskRepository {
  Future<List<TaskModel>> getPendingTasks();
  Future<List<CompletedTaskModel>> getCompletedTasks();
  Future<List<TeamTaskModel>> getTeamTasks();
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId);
  Future<List<CommentModel>> getCommentsForTask(String taskId);
  Future<CommentModel> addComment({
    required String taskId,
    required String text,
    required String userId,
    required String userName,
  });
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  });
}

// ✅ Mock Implementation
class MockTaskRepository implements ITaskRepository {
  @override
  Future<List<TaskModel>> getPendingTasks() async {
    // TODO: GET /api/tasks?status=pending
    await Future.delayed(const Duration(milliseconds: 500));
    return TaskModel.mockTasks;
  }

  @override
  Future<List<CompletedTaskModel>> getCompletedTasks() async {
    // TODO: GET /api/tasks?status=completed
    await Future.delayed(const Duration(milliseconds: 500));
    return CompletedTaskModel.mockCompletedTasks;
  }

  @override
  Future<List<TeamTaskModel>> getTeamTasks() async {
    // TODO: GET /api/team/tasks
    await Future.delayed(const Duration(milliseconds: 300));
    return TeamTaskModel.mockTeamTasks;
  }

  @override
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId) async {
    // TODO: GET /api/tasks/{taskId}/feedback
    await Future.delayed(const Duration(milliseconds: 300));
    return FeedbackModel.mockFeedbacks
        .where((f) => f.taskId == taskId)
        .toList();
  }

  @override
  Future<List<CommentModel>> getCommentsForTask(String taskId) async {
    // TODO: GET /api/tasks/{taskId}/comments
    await Future.delayed(const Duration(milliseconds: 300));
    return CommentModel.mockCommentsForTask(taskId);
  }

  @override
  Future<CommentModel> addComment({
    required String taskId,
    required String text,
    required String userId,
    required String userName,
  }) async {
    // TODO: POST /api/tasks/{taskId}/comments
    await Future.delayed(const Duration(milliseconds: 200));
    return CommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      userId: userId,
      userName: userName,
      text: text,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    // TODO: POST /api/tasks/{taskId}/submit (multipart form)
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}