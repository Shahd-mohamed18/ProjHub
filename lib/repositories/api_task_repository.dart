// lib/repositories/api_task_repository.dart
//
// Swagger URL reference:
//  GET  /api/Tasks/my-tasks {userId}        space+userId in path
//  GET  /api/Tasks/all-tasks-{supervisorId} dash+supervisorId in path
//  GET  /api/Tasks/team/{teamId}            int teamId
//  GET  /api/Tasks/GetTask {id}             space+id in path
//  POST /api/Tasks?supervisorId=…
//  PUT  /api/Tasks/Update{id}?supervisorId=…
//  DEL  /api/Tasks/{id}?supervisorId=…
//  POST /api/Tasks/{id}/submit?studentId=…
//  POST /api/Tasks/{id}/feedback?supervisorId=…
//  POST /api/Tasks/{id}/comments?userId=…   ← body has ONLY "text"
//  DEL  /api/Tasks/comments/{id}?userId=…

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
  static const String _base = 'https://projecthubb.runasp.net';

  // ── auth ──────────────────────────────────────────────────────

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, String>> _headers() async {
    try {
      final token =
          await FirebaseAuth.instance.currentUser?.getIdToken(true);
      _log('🔑 token ${token != null ? "OK" : "NULL"}');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (e) {
      _log('⚠️ token error: $e');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
    }
  }

  // ── HTTP ──────────────────────────────────────────────────────

  Uri _uri(String path, {Map<String, String>? query}) {
    final encoded = Uri.encodeFull('$_base$path');
    final uri = Uri.parse(encoded);
    return query != null && query.isNotEmpty
        ? uri.replace(queryParameters: query)
        : uri;
  }

  Future<http.Response> _get(String path,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    _log('📤 GET $uri');
    final r = await http.get(uri, headers: await _headers());
    _logRes(r);
    _check(r);
    return r;
  }

  Future<http.Response> _post(String path, Object body,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    _log('📤 POST $uri  body=${jsonEncode(body)}');
    final r = await http.post(uri,
        headers: await _headers(), body: jsonEncode(body));
    _logRes(r);
    _check(r);
    return r;
  }

  Future<http.Response> _put(String path, Object body,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    _log('📤 PUT $uri');
    final r = await http.put(uri,
        headers: await _headers(), body: jsonEncode(body));
    _logRes(r);
    _check(r);
    return r;
  }

  Future<http.Response> _delete(String path,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    _log('📤 DELETE $uri');
    final r = await http.delete(uri, headers: await _headers());
    _logRes(r);
    _check(r);
    return r;
  }

  void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException(r.statusCode, r.body);
    }
  }

  void _logRes(http.Response r) {
    final preview =
        r.body.length > 600 ? '${r.body.substring(0, 600)}…' : r.body;
    _log('📥 ${r.statusCode}  $preview');
  }

  // ignore: avoid_print
  void _log(String m) => print(m);

  // ── ITaskRepository ───────────────────────────────────────────

  /// GET /api/Tasks/my-tasks {userId}
  /// Returns all tasks assigned to this student.
  /// Pending = isCompleted false.
  @override
  Future<List<TaskModel>> getPendingTasks({String? userId}) async {
    final uid = userId ?? _uid ?? '';
    _log('📋 getPendingTasks uid=$uid');
    try {
      final r = await _get('/api/Tasks/my-tasks $uid');
      final List data = jsonDecode(r.body);
      _log('📦 raw my-tasks count=${data.length}');
      return data
          .map((j) => TaskModel.fromJson(_norm(j)))
          .where((t) => !t.isCompleted)
          .toList();
    } catch (e) {
      _log('❌ getPendingTasks: $e');
      rethrow;
    }
  }

  /// GET /api/Tasks/my-tasks {userId}  — same call, filter completed=true
  @override
  Future<List<CompletedTaskModel>> getCompletedTasks(
      {String? userId}) async {
    final uid = userId ?? _uid ?? '';
    try {
      final r = await _get('/api/Tasks/my-tasks $uid');
      final List data = jsonDecode(r.body);
      return data
          .map((j) => TaskModel.fromJson(_norm(j)))
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

  /// GET /api/Tasks/team/{teamId}
  /// Fix issue 2: team-wide tasks — called with the student's teamId
  @override
  Future<List<TeamTaskModel>> getTeamTasks({String? teamId}) async {
    if (teamId == null || teamId.isEmpty) return [];
    try {
      final r = await _get('/api/Tasks/team/$teamId');
      final List data = jsonDecode(r.body);
      _log('📦 team tasks count=${data.length}');
      return data.map(_toTeamTask).toList();
    } catch (e) {
      _log('❌ getTeamTasks: $e');
      return [];
    }
  }

  /// GET /api/Tasks/all-tasks-{supervisorId}
  @override
  Future<List<TaskModel>> getTasksBySupervisor(
      String supervisorId) async {
    _log('📋 getTasksBySupervisor id=$supervisorId');
    try {
      final r = await _get('/api/Tasks/all-tasks-$supervisorId');
      final List data = jsonDecode(r.body);
      _log('✅ ${data.length} supervisor tasks');
      return data.map((j) => TaskModel.fromJson(_norm(j))).toList();
    } catch (e) {
      _log('❌ getTasksBySupervisor: $e');
      return [];
    }
  }

  /// GET /api/Tasks/GetTask {id}
  Future<TaskModel> getTaskById(String taskId) async {
    final r = await _get('/api/Tasks/GetTask $taskId');
    return TaskModel.fromJson(_norm(jsonDecode(r.body)));
  }

  /// No GET feedback endpoint in Swagger
  @override
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId) async =>
      [];

  /// No GET comments endpoint in Swagger
  @override
  Future<List<CommentModel>> getCommentsForTask(String taskId) async =>
      [];

  /// POST /api/Tasks/{id}/comments?userId={uid}
  /// Fix issue 4: AddTaskCommentDTO only has "text" — do NOT put
  /// userId/userName in the body, only in the query param.
  @override
  Future<CommentModel> addComment({
    required String taskId,
    required String text,
    required String userId,
    required String userName,
  }) async {
    // ✅ Body = { "text": "…" } only  — matches AddTaskCommentDTO exactly
    final r = await _post(
      '/api/Tasks/$taskId/comments',
      {'text': text},                     // ← ONLY text in body
      query: {'userId': userId},          // ← userId as query param
    );
    try {
      return _toComment(jsonDecode(r.body), taskId);
    } catch (_) {
      return CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId,
        userId: userId,
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
      );
    }
  }

  /// POST /api/Tasks/{id}/submit?studentId={uid}
  @override
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    try {
      final uid = _uid ?? '';
      final attachments = filePaths.map((p) {
        final name = p.split('/').last;
        final type =
            name.contains('.') ? name.split('.').last : 'file';
        return {'name': name, 'type': type};
      }).toList();
      await _post(
        '/api/Tasks/$taskId/submit',
        {'studentAttachments': attachments},
        query: uid.isNotEmpty ? {'studentId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('❌ submitTask: $e');
      return false;
    }
  }

  @override
  Future<PostModel?> getLatestPost() async => null;

  // ── Extra (not in ITaskRepository) ───────────────────────────

  /// POST /api/Tasks?supervisorId={uid}
  /// Fix issue 3 partial: store supervisorName in description prefix
  /// until backend adds a supervisorName field to the response.
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required int teamId,
    required List<String> assignedTo,
    required String supervisorName, // ← pass the real name
  }) async {
    final uid = _uid ?? '';
    final r = await _post(
      '/api/Tasks',
      {
        'title': title,
        'description': description,
        'dueDate': dueDate.toUtc().toIso8601String(),
        'teamId': teamId,
        'assignedTo': assignedTo,
      },
      query: uid.isNotEmpty ? {'supervisorId': uid} : null,
    );
    try {
      final parsed = TaskModel.fromJson(_norm(jsonDecode(r.body)));
      // Patch the from field with the real name
      return parsed.copyWith(from: supervisorName);
    } catch (_) {
      return TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        from: supervisorName,
        dueDate: dueDate,
        teamId: teamId.toString(),
        supervisorId: uid,
        assignedTo: assignedTo,
        description: description,
      );
    }
  }

  /// POST /api/Tasks/{id}/feedback?supervisorId={uid}
  Future<bool> addFeedback({
    required String taskId,
    required String message,
    required String from,
    List<Map<String, String>> attachments = const [],
  }) async {
    try {
      final uid = _uid ?? '';
      await _post(
        '/api/Tasks/$taskId/feedback',
        {'message': message, 'from': from, 'attachments': attachments},
        query: uid.isNotEmpty ? {'supervisorId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('❌ addFeedback: $e');
      return false;
    }
  }

  /// PUT /api/Tasks/Update{id}?supervisorId={uid}
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? assignedTo,
  }) async {
    try {
      final uid = _uid ?? '';
      final body = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (dueDate != null)
          'dueDate': dueDate.toUtc().toIso8601String(),
        if (assignedTo != null) 'assignedTo': assignedTo,
      };
      await _put(
        '/api/Tasks/Update$taskId',
        body,
        query: uid.isNotEmpty ? {'supervisorId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('❌ updateTask: $e');
      return false;
    }
  }

  /// DELETE /api/Tasks/{id}?supervisorId={uid}
  Future<bool> deleteTask(String taskId) async {
    try {
      final uid = _uid ?? '';
      await _delete(
        '/api/Tasks/$taskId',
        query: uid.isNotEmpty ? {'supervisorId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('❌ deleteTask: $e');
      return false;
    }
  }

  /// DELETE /api/Tasks/comments/{id}?userId={uid}
  Future<bool> deleteComment(int commentId) async {
    try {
      final uid = _uid ?? '';
      await _delete(
        '/api/Tasks/comments/$commentId',
        query: uid.isNotEmpty ? {'userId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('❌ deleteComment: $e');
      return false;
    }
  }

  // ── JSON normaliser ───────────────────────────────────────────

  Map<String, dynamic> _norm(Map<String, dynamic> j) {
    // Fix issue 3: supervisor name — try every possible field name
    final supervisorId =
        (j['supervisorId'] ?? j['createdById'] ?? '').toString();
    final fromName = _firstNonEmpty([
      j['from'],
      j['supervisorName'],
      j['createdByName'],
      j['assignedByName'],
      j['fullName'],
    ]) ??
        'Supervisor';

    // Fix issue 2: assignedTo null → empty list (backend omits when "all")
    final assignedTo =
        _strList(j['assignedTo'] ?? j['assigned_to'] ?? j['members']);

    // Fix issue 4: description — backend key might be 'desc' or 'body'
    final description = _firstNonEmpty([
      j['description'],
      j['desc'],
      j['body'],
      j['content'],
    ]);

    return {
      'id': (j['id'] ?? j['taskId'] ?? '').toString(),
      'title': j['title'] ?? '',
      'from': fromName,
      'dueDate': j['dueDate'] ??
          j['due_date'] ??
          DateTime.now().toIso8601String(),
      'teamId': (j['teamId'] ?? j['team_id'] ?? '').toString(),
      'supervisorId': supervisorId,
      'assignedTo': assignedTo,
      'description': description,
      'supervisorAttachments':
          _attachList(j['supervisorAttachments']),
      'studentAttachments': _attachList(j['studentAttachments']),
      'isCompleted':
          j['isCompleted'] ?? j['is_completed'] ?? false,
    };
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return null;
  }

  List<String> _strList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }

  List<Map<String, String>>? _attachList(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      return v.map<Map<String, String>>((e) {
        final m = e as Map<String, dynamic>;
        return {
          'name': (m['name'] ?? '').toString(),
          'type': (m['type'] ?? '').toString()
        };
      }).toList();
    }
    return null;
  }

  TeamTaskModel _toTeamTask(dynamic j) {
    final m = j as Map<String, dynamic>;
    return TeamTaskModel(
      id: (m['id'] ?? '').toString(),
      title: m['title'] ?? '',
      assignedTo: _assignedDisplay(m['assignedTo']),
      dueDate: m['dueDate'] != null
          ? DateTime.tryParse(m['dueDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String _assignedDisplay(dynamic v) {
    if (v == null) return 'Team';
    if (v is List && v.isNotEmpty) {
      if (v.first is Map) {
        return (v.first as Map)['name']?.toString() ?? 'Member';
      }
      return v.length == 1
          ? v.first.toString()
          : '${v.length} members';
    }
    return v.toString();
  }

  CommentModel _toComment(Map<String, dynamic> j, String taskId) =>
      CommentModel(
        id: (j['id'] ?? '').toString(),
        taskId: taskId,
        userId: (j['userId'] ?? j['user_id'] ?? '').toString(),
        userName: j['userName'] ?? j['user_name'] ?? 'Unknown',
        text: j['text'] ?? '',
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString()) ??
                DateTime.now()
            : DateTime.now(),
      );
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}