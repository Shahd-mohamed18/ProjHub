// lib/repositories/mock_task_repository.dart
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/task_repository.dart';

class MockTaskRepository implements ITaskRepository {

  // ✅ الطالب يشوف بس التاسكات المأسندة ليه
  @override
  Future<List<TaskModel>> getPendingTasks({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tasks = TaskModel.mockTasks.where((t) => !t.isCompleted);
    if (userId != null) {
      return tasks.where((t) => t.isAssignedTo(userId)).toList();
    }
    return tasks.toList();
  }

  @override
  Future<List<CompletedTaskModel>> getCompletedTasks({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CompletedTaskModel.mockCompletedTasks;
  }

  @override
  Future<List<TeamTaskModel>> getTeamTasks({String? teamId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return TeamTaskModel.mockTeamTasks;
  }

  // ✅ الدكتور يشوف كل التاسكات اللي هو عملها
  @override
  Future<List<TaskModel>> getTasksBySupervisor(String supervisorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // مؤقتاً بيرجع كل التاسكات - لما يجي الـ backend هيفلتر بالـ supervisorId
    return TaskModel.mockTasks;
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

  // ✅ لما الطالب يرفع - التاسك بيتحرك من pending لـ completed
  @override
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    TaskModel.markAsCompleted(taskId, filePaths);
    return true;
  }

  @override
  Future<PostModel?> getLatestPost() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }
}