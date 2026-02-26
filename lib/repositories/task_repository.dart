// lib/repositories/task_repository.dart
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';

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
  Future<PostModel?> getLatestPost();
}