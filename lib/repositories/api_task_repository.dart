// lib/repositories/api_task_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/models/TaskModels/comment_model.dart';
import 'package:onboard/models/CommunityModels/post_model.dart';
import 'package:onboard/repositories/task_repository.dart';

class ApiTaskRepository implements ITaskRepository {
  static const String _baseUrl = 'https://projecthubb.runasp.net';

  // ── auth ────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    try {
      // forceRefresh=true ensures we never send an expired token
      final token =
          await FirebaseAuth.instance.currentUser?.getIdToken(true);
      _log('🔑 Token: ${token != null ? "OK (${token.length} chars)" : "NULL"}');
      return token;
    } catch (e) {
      _log('⚠️ Token error: $e');
      return null;
    }
  }

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── HTTP helpers ─────────────────────────────────────────────

  Future<http.Response> _get(
    String path, {
    Map<String, String>? query,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    _log('📤 GET $uri');
    final response = await http.get(uri, headers: await _headers());
    _logResponse(response);
    _assertSuccess(response);
    return response;
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    _log('📤 POST $uri  body=${jsonEncode(body)}');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _logResponse(response);
    _assertSuccess(response);
    return response;
  }

  Future<http.Response> _put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    _log('📤 PUT $uri');
    final response = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _logResponse(response);
    _assertSuccess(response);
    return response;
  }

  Future<http.Response> _delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    _log('📤 DELETE $uri');
    final response = await http.delete(uri, headers: await _headers());
    _logResponse(response);
    _assertSuccess(response);
    return response;
  }

  void _logResponse(http.Response r) {
    final preview = r.body.length > 400
        ? '${r.body.substring(0, 400)}…'
        : r.body;
    _log('📥 ${r.statusCode}  body=$preview');
  }

  void _assertSuccess(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException(r.statusCode, r.body);
    }
  }

  // ignore: avoid_print
  void _log(String msg) => print(msg);

  // ── ITaskRepository ──────────────────────────────────────────

  /// Student pending tasks — GET /api/Tasks/my-tasks?userId={uid}
  @override
  Future<List<TaskModel>> getPendingTasks({String? userId}) async {
    try {
      final uid = userId ?? _currentUid ?? '';
      _log('📋 getPendingTasks  uid=$uid');
      final response = await _get(
        '/api/Tasks/my-tasks',
        query: uid.isNotEmpty ? {'userId': uid} : null,
      );
      final List<dynamic> data = jsonDecode(response.body);
      final all = data
          .map((j) => TaskModel.fromJson(_normaliseTask(j)))
          .toList();
      return all.where((t) => !t.isCompleted).toList();
    } catch (e) {
      _log('❌ getPendingTasks: $e');
      rethrow;
    }
  }

  /// Student completed tasks — GET /api/Tasks/my-tasks?userId={uid}
  @override
  Future<List<CompletedTaskModel>> getCompletedTasks({
    String? userId,
  }) async {
    try {
      final uid = userId ?? _currentUid ?? '';
      final response = await _get(
        '/api/Tasks/my-tasks',
        query: uid.isNotEmpty ? {'userId': uid} : null,
      );
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((j) => TaskModel.fromJson(_normaliseTask(j)))
          .where((t) => t.isCompleted)
          .map((t) => CompletedTaskModel(
                id: t.id,
                title: t.title,
                completedDate: t.dueDate,
                status: 'Approved',
                hasFeedback: true,
              ))
          .toList();
    } catch (e) {
      _log('❌ getCompletedTasks: $e');
      rethrow;
    }
  }

  /// Team tasks — GET /api/Tasks/team/{teamId}
  @override
  Future<List<TeamTaskModel>> getTeamTasks({String? teamId}) async {
    if (teamId == null || teamId.isEmpty) return [];
    try {
      final response = await _get('/api/Tasks/team/$teamId');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map(_teamTaskFromJson).toList();
    } catch (e) {
      _log('❌ getTeamTasks: $e');
      return [];
    }
  }

  /// Supervisor all tasks.
  ///
  /// The supervisorId is sent in THREE places so the backend can use
  /// whichever convention it follows:
  ///   • Query param  ?supervisorId=…
  ///   • Query param  ?userId=…       (alias)
  ///   • Bearer token                 (Authorization header)
  @override
  Future<List<TaskModel>> getTasksBySupervisor(
    String supervisorId,
  ) async {
    _log('📋 getTasksBySupervisor  supervisorId=$supervisorId');
    try {
      final response = await _get(
        '/api/Tasks/all-tasks',
        query: {
          'supervisorId': supervisorId,
          'userId': supervisorId,
        },
      );
      final List<dynamic> data = jsonDecode(response.body);
      _log('✅ ${data.length} supervisor tasks received');
      return data
          .map((j) => TaskModel.fromJson(_normaliseTask(j)))
          .toList();
    } catch (e) {
      _log('❌ getTasksBySupervisor: $e');
      // Return empty list — AllTasksScreen shows "No tasks yet" gracefully
      return [];
    }
  }

  /// Feedback for a task — GET /api/Tasks/{id}/feedback
  @override
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId) async {
    try {
      final response = await _get('/api/Tasks/$taskId/feedback');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => _feedbackFromJson(j, taskId)).toList();
    } catch (e) {
      _log('❌ getFeedbackForTask: $e');
      return [];
    }
  }

  /// Comments — GET /api/Tasks/{id}/comments
  @override
  Future<List<CommentModel>> getCommentsForTask(String taskId) async {
    try {
      final response = await _get('/api/Tasks/$taskId/comments');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => _commentFromJson(j, taskId)).toList();
    } catch (e) {
      _log('❌ getCommentsForTask: $e');
      return [];
    }
  }

  /// Add comment — POST /api/Tasks/{id}/comments
  @override
  Future<CommentModel> addComment({
    required String taskId,
    required String text,
    required String userId,
    required String userName,
  }) async {
    final response = await _post('/api/Tasks/$taskId/comments', {
      'text': text,
      'userId': userId,
      'userName': userName,
    });
    return _commentFromJson(jsonDecode(response.body), taskId);
  }

  /// Submit task — POST /api/Tasks/{id}/submit
  @override
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    try {
      final attachments = filePaths.map((path) {
        final name = path.split('/').last;
        final ext = name.contains('.') ? name.split('.').last : 'file';
        return {'name': name, 'type': ext};
      }).toList();

      await _post('/api/Tasks/$taskId/submit', {
        'studentAttachments': attachments,
      });
      return true;
    } catch (e) {
      _log('❌ submitTask: $e');
      return false;
    }
  }

  @override
  Future<PostModel?> getLatestPost() async => null;

  // ── Extra methods (not in ITaskRepository) ───────────────────

  /// Create task — POST /api/Tasks
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required int teamId,
    required List<String> assignedTo,
    List<Map<String, String>> attachments = const [],
  }) async {
    final response = await _post('/api/Tasks', {
      'title': title,
      'description': description,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'teamId': teamId,
      'assignedTo': assignedTo,
      if (attachments.isNotEmpty) 'supervisorAttachments': attachments,
    });
    return TaskModel.fromJson(_normaliseTask(jsonDecode(response.body)));
  }

  /// Add feedback — POST /api/Tasks/{id}/feedback
  Future<FeedbackModel> addFeedback({
    required String taskId,
    required String message,
    required String from,
    List<Map<String, String>> attachments = const [],
  }) async {
    final response = await _post('/api/Tasks/$taskId/feedback', {
      'message': message,
      'from': from,
      'attachments': attachments,
    });
    return _feedbackFromJson(jsonDecode(response.body), taskId);
  }

  /// Update task — PUT /api/Tasks/{id}
  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? assignedTo,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': dueDate.toUtc().toIso8601String(),
      if (assignedTo != null) 'assignedTo': assignedTo,
    };
    final response = await _put('/api/Tasks/$taskId', body);
    return TaskModel.fromJson(_normaliseTask(jsonDecode(response.body)));
  }

  /// Delete task — DELETE /api/Tasks/{id}
  Future<bool> deleteTask(String taskId) async {
    try {
      await _delete('/api/Tasks/$taskId');
      return true;
    } catch (e) {
      _log('❌ deleteTask: $e');
      return false;
    }
  }

  // ── JSON normalisers ─────────────────────────────────────────

  Map<String, dynamic> _normaliseTask(Map<String, dynamic> j) {
    return {
      'id': (j['id'] ?? j['taskId'] ?? '').toString(),
      'title': j['title'] ?? '',
      'from': j['from'] ??
          j['createdBy'] ??
          j['supervisorName'] ??
          'Supervisor',
      'dueDate':
          j['dueDate'] ?? j['due_date'] ?? DateTime.now().toIso8601String(),
      'teamId': (j['teamId'] ?? j['team_id'] ?? '').toString(),
      'supervisorId':
          (j['supervisorId'] ?? j['createdById'] ?? '').toString(),
      'assignedTo': _parseStringList(j['assignedTo'] ?? j['assigned_to']),
      'description': j['description'],
      'supervisorAttachments':
          _parseAttachments(j['supervisorAttachments']),
      'studentAttachments': _parseAttachments(j['studentAttachments']),
      'isCompleted': j['isCompleted'] ?? j['is_completed'] ?? false,
    };
  }

  List<String> _parseStringList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  List<Map<String, String>>? _parseAttachments(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      return v.map<Map<String, String>>((e) {
        final m = e as Map<String, dynamic>;
        return {
          'name': (m['name'] ?? '').toString(),
          'type': (m['type'] ?? '').toString(),
        };
      }).toList();
    }
    return null;
  }

  TeamTaskModel _teamTaskFromJson(dynamic j) {
    final m = j as Map<String, dynamic>;
    return TeamTaskModel(
      id: (m['id'] ?? '').toString(),
      title: m['title'] ?? '',
      assignedTo: _assignedToDisplay(m['assignedTo']),
      dueDate: m['dueDate'] != null
          ? DateTime.tryParse(m['dueDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String _assignedToDisplay(dynamic v) {
    if (v == null) return 'Team';
    if (v is List && v.isNotEmpty) {
      if (v.first is Map) {
        return (v.first as Map)['name']?.toString() ?? 'Member';
      }
      return v.length == 1 ? v.first.toString() : '${v.length} members';
    }
    return v.toString();
  }

  FeedbackModel _feedbackFromJson(Map<String, dynamic> j, String taskId) {
    return FeedbackModel(
      id: (j['id'] ?? '').toString(),
      taskId: taskId,
      from: j['from'] ?? 'Supervisor',
      message: j['message'] ?? '',
      date: j['date'] != null
          ? DateTime.tryParse(j['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      attachments: (j['attachments'] as List? ?? [])
          .map((a) => AttachmentModel(
                name: (a['name'] ?? '').toString(),
                type: (a['type'] ?? '').toString(),
              ))
          .toList(),
    );
  }

  CommentModel _commentFromJson(Map<String, dynamic> j, String taskId) {
    return CommentModel(
      id: (j['id'] ?? '').toString(),
      taskId: taskId,
      userId: (j['userId'] ?? j['user_id'] ?? '').toString(),
      userName: j['userName'] ?? j['user_name'] ?? 'Unknown',
      text: j['text'] ?? '',
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}