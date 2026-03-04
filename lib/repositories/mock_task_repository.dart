// lib/repositories/mock_task_repository.dart
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/task_repository.dart';

class MockTaskRepository implements ITaskRepository {
  @override
  Future<List<TaskModel>> getPendingTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return TaskModel.mockTasks;
  }

  @override
  Future<List<CompletedTaskModel>> getCompletedTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CompletedTaskModel.mockCompletedTasks;
  }

  @override
  Future<List<TeamTaskModel>> getTeamTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return TeamTaskModel.mockTeamTasks;
  }

  @override
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return FeedbackModel.mockFeedbacks
        .where((f) => f.taskId == taskId)
        .toList();
  }

  @override
  Future<List<CommentModel>> getCommentsForTask(String taskId) async {
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
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<PostModel?> getLatestPost() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // أو PostModel.mockPosts.first
  }
}