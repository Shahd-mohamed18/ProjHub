// lib/repositories/api_task_repository.dart
//
// ✅ FIXED:
//  • getCommentsForTask uses GET /api/Tasks/{id}/comments  (was returning [])
//  • getFeedbackForTask uses GET /api/Tasks/{id}/feedback  (dedicated endpoint)
//  • getTaskById uses GET /api/Tasks/{id}  – full detail incl. attachments
//  • After submitTask the task is still fetchable (no local mutation)
//  • _norm maps every backend key variant correctly

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

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, String>> _headers() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (_) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final uri = Uri.parse('$_base$path');
    return (query != null && query.isNotEmpty)
        ? uri.replace(queryParameters: query)
        : uri;
  }

  Future<http.Response> _get(String path, {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    _log('GET $uri');
    final r = await http.get(uri, headers: await _headers());
    _logRes(r);
    _check(r);
    return r;
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    final encoded = jsonEncode(body);
    _log('POST $uri  body=$encoded');
    final r = await http.post(uri, headers: await _headers(), body: encoded);
    _logRes(r);
    _check(r);
    return r;
  }

  Future<http.Response> _put(String path, Map<String, dynamic> body,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
    final r =
        await http.put(uri, headers: await _headers(), body: jsonEncode(body));
    _logRes(r);
    _check(r);
    return r;
  }

  Future<http.Response> _delete(String path,
      {Map<String, String>? query}) async {
    final uri = _uri(path, query: query);
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
    final p = r.body.length > 800 ? '${r.body.substring(0, 800)}...' : r.body;
    _log('${r.statusCode}  $p');
  }

  void _log(String m) => print('[ApiTask] $m');

  // ─────────────────────────────────────────────────────────────
  // ITaskRepository
  // ─────────────────────────────────────────────────────────────

  /// GET /api/Tasks/{id}  — single task, full detail incl. attachments
  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final r = await _get('/api/Tasks/$taskId');
      final raw = jsonDecode(r.body) as Map<String, dynamic>;
      // Parse directly from raw JSON so supervisorAttachments is read as-is
      // from the backend without going through _norm (which is for list items).
      final task = TaskModel.fromJson(raw);
      _log('getTaskById supervisorAttachments count: '
          '${task.supervisorAttachments?.length ?? 0}');
      return task;
    } catch (e) {
      _log('getTaskById error: $e');
      return null;
    }
  }

  /// GET /api/Tasks/my-tasks?userId=  →  pending tasks for this student
  @override
  Future<List<TaskModel>> getPendingTasks({String? userId}) async {
    final uid = userId ?? _uid ?? '';
    try {
      final r = await _get('/api/Tasks/my-tasks',
          query: uid.isNotEmpty ? {'userId': uid} : null);
      final List data = jsonDecode(r.body);
      final all = data.map((j) => TaskModel.fromJson(_norm(j))).toList();
      return all.where((t) => !t.isCompleted).toList();
    } catch (e) {
      _log('getPendingTasks error: $e');
      rethrow;
    }
  }

  /// GET /api/Tasks/my-tasks?userId=  →  completed tasks for this student
  @override
  Future<List<CompletedTaskModel>> getCompletedTasks({String? userId}) async {
    final uid = userId ?? _uid ?? '';
    try {
      final r = await _get('/api/Tasks/my-tasks',
          query: uid.isNotEmpty ? {'userId': uid} : null);
      final List data = jsonDecode(r.body);
      final completedTasks = data
          .map((j) => TaskModel.fromJson(_norm(j)))
          .where((t) => t.isCompleted)
          .toList();

      // Fetch full detail for each completed task so supervisor attachments
      // are included (the list endpoint often omits them).
      final List<CompletedTaskModel> result = [];
      for (final t in completedTasks) {
        TaskModel fullTask = t;
        try {
          final detail = await getTaskById(t.id);
          if (detail != null) {
            // If detail drops supervisor attachments but list had them, keep list version
            final supAttach =
                (detail.supervisorAttachments == null ||
                        detail.supervisorAttachments!.isEmpty)
                    ? t.supervisorAttachments
                    : detail.supervisorAttachments;
            fullTask = detail.copyWith(supervisorAttachments: supAttach);
          }
        } catch (_) {
          // fallback to list data if detail fetch fails
        }
        result.add(CompletedTaskModel(
          id: fullTask.id,
          title: fullTask.title,
          completedDate: fullTask.dueDate,
          status: 'Approved',
          hasFeedback: true,
          taskModel: fullTask, // full data including supervisor attachments
        ));
      }
      return result;
    } catch (e) {
      _log('getCompletedTasks error: $e');
      rethrow;
    }
  }

  /// GET /api/Tasks/team/{teamId}
  @override
  Future<List<TeamTaskModel>> getTeamTasks({String? teamId}) async {
    if (teamId == null || teamId.isEmpty) return [];
    try {
      final r = await _get('/api/Tasks/team/$teamId');
      final List data = jsonDecode(r.body);
      return data.map(_toTeamTask).toList();
    } catch (e) {
      _log('getTeamTasks error: $e');
      return [];
    }
  }

  /// GET /api/Tasks/all-tasks?supervisorId=
  @override
  Future<List<TaskModel>> getTasksBySupervisor(String supervisorId) async {
    try {
      final r = await _get('/api/Tasks/all-tasks',
          query: {'supervisorId': supervisorId});
      final List data = jsonDecode(r.body);
      return data.map((j) => TaskModel.fromJson(_norm(j))).toList();
    } catch (e) {
      _log('getTasksBySupervisor error: $e');
      return [];
    }
  }

  // ── FEEDBACK ──────────────────────────────────────────────────
  //
  // ✅ Uses the dedicated endpoint: GET /api/Tasks/{id}/feedback
  // Falls back to reading from GET /api/Tasks/{id} body if needed.

  @override
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId) async {
    _log('getFeedbackForTask taskId=$taskId');

    // 1️⃣ Try dedicated feedback endpoint first
    try {
      final r = await _get('/api/Tasks/$taskId/feedback');
      final body = jsonDecode(r.body);

      List<dynamic> raw = [];
      if (body is List) {
        raw = body;
      } else if (body is Map) {
        raw = body['feedbacks'] ??
            body['feedback'] ??
            body['taskFeedbacks'] ??
            body['data'] ??
            [];
      }

      if (raw.isNotEmpty) {
        _log('${raw.length} feedbacks from /feedback endpoint');
        return raw
            .map((f) => FeedbackModel.fromJson({
                  ...f as Map<String, dynamic>,
                  'taskId': taskId,
                }))
            .toList();
      }
    } catch (e) {
      _log('Dedicated /feedback endpoint failed: $e – falling back to task detail');
    }

    // 2️⃣ Fallback: read feedbacks[] embedded in GET /api/Tasks/{id}
    try {
      final r = await _get('/api/Tasks/$taskId');
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final raw = j['feedbacks'] ??
          j['feedback'] ??
          j['taskFeedbacks'] ??
          j['taskFeedback'] ??
          j['reviews'];

      if (raw is List && raw.isNotEmpty) {
        _log('${raw.length} feedbacks from task detail fallback');
        return raw
            .map((f) => FeedbackModel.fromJson({
                  ...f as Map<String, dynamic>,
                  'taskId': taskId,
                }))
            .toList();
      }
    } catch (e) {
      _log('getFeedbackForTask fallback error: $e');
    }

    _log('No feedbacks found for task $taskId');
    return [];
  }

  // ── COMMENTS ──────────────────────────────────────────────────
  //
  // ✅ FIXED: was returning [] — now calls GET /api/Tasks/{id}/comments

  @override
  Future<List<CommentModel>> getCommentsForTask(String taskId) async {
    _log('getCommentsForTask taskId=$taskId');
    try {
      final r = await _get('/api/Tasks/$taskId/comments');
      final body = jsonDecode(r.body);

      List<dynamic> raw = [];
      if (body is List) {
        raw = body;
      } else if (body is Map) {
        raw = body['comments'] ?? body['data'] ?? [];
      }

      _log('${raw.length} comments loaded');
      return raw.map((j) => CommentModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      _log('getCommentsForTask error: $e');
      return [];
    }
  }

  /// POST /api/Tasks/{id}/comments?userId=
  @override
  Future<CommentModel> addComment({
    required String taskId,
    required String text,
    required String userId,
    required String userName,
  }) async {
    final r = await _post(
      '/api/Tasks/$taskId/comments',
      {'text': text},
      query: {'userId': userId},
    );
    try {
      return _toComment(jsonDecode(r.body), taskId, userId, userName);
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

  /// POST /api/Tasks/{id}/submit?studentId=
  @override
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    try {
      final uid = _uid ?? '';
      final attachments = filePaths.map((p) {
        final name = p.split('/').last;
        final type = name.contains('.') ? name.split('.').last : 'file';
        return <String, String>{'name': name, 'type': type};
      }).toList();

      await _post(
        '/api/Tasks/$taskId/submit',
        {'studentAttachments': attachments},
        query: uid.isNotEmpty ? {'studentId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('submitTask error: $e');
      return false;
    }
  }

  @override
  Future<PostModel?> getLatestPost() async => null;

  // ── Extra methods ─────────────────────────────────────────────

  /// POST /api/Tasks?supervisorId=
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required int teamId,
    required List<String> assignedTo,
    required String supervisorName,
    List<Map<String, String>> supervisorAttachments = const [],
  }) async {
    final uid = _uid ?? '';
    final body = {
      'title': title,
      'description': description,
      'dueDate': dueDate.toUtc().toIso8601String(),
      'teamId': teamId,
      'assignedTo': assignedTo,
      'supervisorAttachments': supervisorAttachments,
    };
    final r = await _post('/api/Tasks', body,
        query: uid.isNotEmpty ? {'supervisorId': uid} : null);
    try {
      final parsed = TaskModel.fromJson(_norm(jsonDecode(r.body)));
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

  /// POST /api/Tasks/{id}/feedback?supervisorId=
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
      _log('addFeedback error: $e');
      return false;
    }
  }

  /// PUT /api/Tasks/{id}?supervisorId=
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? assignedTo,
  }) async {
    try {
      final uid = _uid ?? '';
      await _put(
        '/api/Tasks/$taskId',
        {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (dueDate != null) 'dueDate': dueDate.toUtc().toIso8601String(),
          if (assignedTo != null) 'assignedTo': assignedTo,
        },
        query: uid.isNotEmpty ? {'supervisorId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('updateTask error: $e');
      return false;
    }
  }

  /// DELETE /api/Tasks/{id}?supervisorId=
  Future<bool> deleteTask(String taskId) async {
    try {
      final uid = _uid ?? '';
      await _delete('/api/Tasks/$taskId',
          query: uid.isNotEmpty ? {'supervisorId': uid} : null);
      return true;
    } catch (e) {
      _log('deleteTask error: $e');
      return false;
    }
  }

  /// DELETE /api/Tasks/comments/{commentId}?userId=
  Future<bool> deleteComment(int commentId) async {
    try {
      final uid = _uid ?? '';
      await _delete('/api/Tasks/comments/$commentId',
          query: uid.isNotEmpty ? {'userId': uid} : null);
      return true;
    } catch (e) {
      _log('deleteComment error: $e');
      return false;
    }
  }

  // ── JSON normaliser ───────────────────────────────────────────

  Map<String, dynamic> _norm(Map<String, dynamic> j) {
    final supervisorId =
        (j['supervisorId'] ?? j['createdById'] ?? '').toString();

    // Determine who this task is "from".
    // For tasks created by the supervisor, use the supervisor name.
    // For submitted tasks shown to the supervisor, also check student fields.
    final fromName = _firstNonEmpty([
      j['from'],
      j['supervisorName'],
      j['supervisorFullName'],
      j['createdByName'],
      j['assignedByName'],
      j['createdBy'],
      j['submittedByName'],
      j['studentName'],
      j['fullName'],
      j['userName'],
    ]) ??
        'Supervisor';

    final description = _firstNonEmpty([
      j['description'],
      j['desc'],
      j['body'],
      j['content'],
      j['taskDescription'],
    ]);

    final assignedTo =
        _strList(j['assignedTo'] ?? j['assigned_to'] ?? j['members']);

    final dueDateStr = (j['dueDate'] ?? j['due_date'])?.toString() ??
        DateTime.now().toIso8601String();

    // supervisorAttachments: ONLY read the specific key.
    // Do NOT fall back to the generic 'attachments' key because after a
    // student submits, the backend may put the student files there and
    // the doctor's original files would be lost.
    final supAttach = _attachList(
      j['supervisorAttachments'] ?? j['taskAttachments'],
    );
    // studentAttachments: after submit these may come under 'attachments'
    // or 'submissions' if the specific key is absent.
    final stuAttach = _attachList(
      j['studentAttachments'] ?? j['submissions'] ?? j['attachments'],
    );

    final isCompleted = j['isCompleted'] ?? j['is_completed'] ?? false;

    // Extract who submitted the task (student side)
    final submittedByName = _firstNonEmpty([
      j['submittedByName'],
      j['studentName'],
      j['submittedBy'],
      j['submitterName'],
      j['submitterFullName'],
    ]);

    return {
      'id': (j['id'] ?? j['taskId'] ?? '').toString(),
      'title': (j['title'] ?? '').toString(),
      'from': fromName,
      'dueDate': dueDateStr,
      'teamId': (j['teamId'] ?? j['team_id'] ?? '').toString(),
      'supervisorId': supervisorId,
      'assignedTo': assignedTo,
      'description': description,
      'supervisorAttachments': supAttach,
      'studentAttachments': stuAttach,
      'isCompleted': isCompleted,
      'submittedByName': submittedByName,
    };
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
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
    if (v is List && v.isEmpty) return [];
    if (v is List) {
      return v.map<Map<String, String>>((e) {
        final m = e as Map<String, dynamic>;
        return {
          'name': (m['name'] ?? m['fileName'] ?? '').toString(),
          'type': (m['type'] ?? m['fileType'] ?? 'file').toString(),
        };
      }).toList();
    }
    return null;
  }

  TeamTaskModel _toTeamTask(dynamic j) {
    final m = j as Map<String, dynamic>;
    return TeamTaskModel(
      id: (m['id'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      assignedTo: _assignedDisplay(m['assignedTo']),
      dueDate: m['dueDate'] != null
          ? DateTime.tryParse(m['dueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String _assignedDisplay(dynamic v) {
    if (v == null) return 'Team';
    if (v is List && v.isNotEmpty) {
      if (v.first is Map) return (v.first as Map)['name']?.toString() ?? 'Member';
      return v.length == 1 ? v.first.toString() : '${v.length} members';
    }
    return v.toString();
  }

  CommentModel _toComment(
      Map<String, dynamic> j, String taskId, String userId, String userName) {
    final rawName = j['userName'] ??
        j['user_name'] ??
        j['authorName'] ??
        j['fullName'] ??
        j['name'] ??
        '';
    final resolvedName =
        (rawName.toString().isEmpty || rawName.toString() == 'Unknown')
            ? userName
            : rawName.toString();

    return CommentModel(
      id: (j['id'] ?? '').toString(),
      taskId: taskId,
      userId: (j['userId'] ?? j['user_id'] ?? userId).toString(),
      userName: resolvedName,
      text: (j['text'] ?? j['content'] ?? '').toString(),
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException($statusCode): $body';
}