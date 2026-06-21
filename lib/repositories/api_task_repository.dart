import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
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

  Future<Map<String, String>> _authHeaders() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      return {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (_) {
      return {'Accept': 'application/json'};
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
    final encoded = jsonEncode(body);
    _log('PUT $uri  body=$encoded');
    final r =
        await http.put(uri, headers: await _headers(), body: encoded);
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

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final r = await _get('/api/Tasks/$taskId');
      final raw = jsonDecode(r.body) as Map<String, dynamic>;
      final task = TaskModel.fromJson(_norm(raw));
      _log('getTaskById supervisorAttachments count: '
          '${task.supervisorAttachments?.length ?? 0}');
      for (final a in (task.supervisorAttachments ?? const [])) {
        _log('  supervisorAttachment: name="${a['name']}" '
            'type="${a['type']}" fileUrl="${a['fileUrl']}"');
      }
      return task;
    } catch (e) {
      _log('getTaskById error: $e');
      return null;
    }
  }

  @override
  Future<List<TaskModel>> getPendingTasks({String? userId}) async {
    final uid = userId ?? _uid ?? '';
    try {
      final r = await _get('/api/Tasks/my-tasks',
          query: uid.isNotEmpty ? {'userId': uid} : null);
      final List data = jsonDecode(r.body);
      _log('getPendingTasks: my-tasks returned ${data.length} raw tasks '
          'for uid=$uid');
      final all = data.map((j) => TaskModel.fromJson(_norm(j))).toList();
      for (final t in all) {
        _log('  task="${t.title}" id=${t.id} isCompleted=${t.isCompleted} '
            'assignedTo=${t.assignedTo} teamId=${t.teamId}');
      }
      return all.where((t) => !t.isCompleted).toList();
    } catch (e) {
      _log('getPendingTasks error: $e');
      rethrow;
    }
  }

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

      final List<CompletedTaskModel> result = [];
      for (final t in completedTasks) {
        TaskModel fullTask = t;
        try {
          final detail = await getTaskById(t.id);
          if (detail != null) {
            final supAttach =
                (detail.supervisorAttachments == null ||
                        detail.supervisorAttachments!.isEmpty)
                    ? t.supervisorAttachments
                    : detail.supervisorAttachments;
            fullTask = detail.copyWith(supervisorAttachments: supAttach);
          }
        } catch (_) {}
        result.add(CompletedTaskModel(
          id: fullTask.id,
          title: fullTask.title,
          completedDate: fullTask.dueDate,
          status: 'Approved',
          hasFeedback: true,
          taskModel: fullTask,
        ));
      }
      return result;
    } catch (e) {
      _log('getCompletedTasks error: $e');
      rethrow;
    }
  }

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

  @override
  Future<List<TaskModel>> getTasksBySupervisor(String supervisorId) async {
    try {
      final r = await _get('/api/Tasks/all-tasks',
          query: {'supervisorId': supervisorId});
      final List data = jsonDecode(r.body);
      final tasks = data.map((j) => TaskModel.fromJson(_norm(j))).toList();
      for (final t in tasks) {
        _log('all-tasks: "${t.title}" id=${t.id} assignedTo=${t.assignedTo} '
            'teamId=${t.teamId} isCompleted=${t.isCompleted}');
      }
      return tasks;
    } catch (e) {
      _log('getTasksBySupervisor error: $e');
      return [];
    }
  }

  // ── FEEDBACK ──────────────────────────────────────────────────

  @override
  Future<List<FeedbackModel>> getFeedbackForTask(String taskId) async {
    _log('getFeedbackForTask taskId=$taskId');

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

  @override
  Future<bool> submitTask({
    required String taskId,
    required List<String> filePaths,
  }) async {
    try {
      final uid = _uid ?? '';
      final uri = _uri('/api/Tasks/$taskId/submit',
          query: uid.isNotEmpty ? {'studentId': uid} : null);

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _authHeaders());

      for (final path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          request.files
              .add(await http.MultipartFile.fromPath('StudentFiles', path));
        } else {
          _log('submitTask: skipping missing file path "$path"');
        }
      }

      _log('POST(multipart) $uri  files=${request.files.length}');
      final streamed = await request.send();
      final r = await http.Response.fromStream(streamed);
      _logRes(r);
      _check(r);
      return true;
    } catch (e) {
      _log('submitTask error: $e');
      return false;
    }
  }

  @override
  Future<PostModel?> getLatestPost() async => null;

  // ── Extra methods ─────────────────────────────────────────────

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required int teamId,
    required List<String> assignedTo,
    required String supervisorName,
    List<PlatformFile> supervisorFiles = const [],
  }) async {
    final uid = _uid ?? '';
    final uri = _uri('/api/Tasks',
        query: uid.isNotEmpty ? {'supervisorId': uid} : null);

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _authHeaders());

    request.fields['Title'] = title;
    request.fields['Description'] = description;
    request.fields['DueDate'] = dueDate.toUtc().toIso8601String();
    request.fields['TeamId'] = teamId.toString();

    for (final id in assignedTo) {
      request.files.add(http.MultipartFile.fromString('AssignedTo', id));
    }
    for (var i = 0; i < assignedTo.length; i++) {
      request.fields['AssignedTo[$i]'] = assignedTo[i];
    }
    if (assignedTo.isNotEmpty) {
      request.fields['AssignedToJson'] = jsonEncode(assignedTo);
      request.fields['AssignedToCsv'] = assignedTo.join(',');
    }

    for (final f in supervisorFiles) {
      if (f.path != null) {
        request.files.add(
            await http.MultipartFile.fromPath('SupervisorFiles', f.path!));
      } else if (f.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'SupervisorFiles',
          f.bytes!,
          filename: f.name,
        ));
      }
    }

    _log('POST(multipart) $uri  fields=${request.fields}  '
        'AssignedTo=$assignedTo  files=${request.files.length}');
    final streamed = await request.send();
    final r = await http.Response.fromStream(streamed);
    _logRes(r);
    _check(r);

    Map<String, dynamic> norm;
    try {
      norm = _norm(jsonDecode(r.body));
    } catch (_) {
      norm = {};
    }
    _log('createTask response assignedTo=${norm['assignedTo']}');

    final createdId = (norm['id'] ?? '').toString();
    final returnedAssigned = (norm['assignedTo'] as List?) ?? const [];
    if (createdId.isNotEmpty &&
        assignedTo.isNotEmpty &&
        returnedAssigned.isEmpty) {
      _log('createTask: assignedTo was dropped by the backend — '
          'patching via PUT /api/Tasks/$createdId');
      final patched = await updateTask(
        taskId: createdId,
        assignedTo: assignedTo,
      );
      _log('createTask: assignedTo patch ${patched ? 'succeeded' : 'failed'}');
      if (patched) {
        final verify = await getTaskById(createdId);
        _log('createTask: verify after patch — '
            'assignedTo=${verify?.assignedTo}');
        if (verify != null && verify.assignedTo.isNotEmpty) {
          norm = {...norm, 'assignedTo': verify.assignedTo};
        } else {
          _log('⚠️ createTask: PUT reported success but assignedTo is '
              'STILL empty after re-fetch. The backend is not persisting '
              'assignedTo on update either — this needs a backend fix.');
        }
      }
    }

    try {
      final parsed = TaskModel.fromJson(norm);
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

  Future<bool> addFeedback({
    required String taskId,
    required String message,
    required String from,
  }) async {
    try {
      final uid = _uid ?? '';
      await _post(
        '/api/Tasks/$taskId/feedback',
        {'message': message, 'from': from},
        query: uid.isNotEmpty ? {'supervisorId': uid} : null,
      );
      return true;
    } catch (e) {
      _log('addFeedback error: $e');
      return false;
    }
  }

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

    final supAttach = _attachList(
      j['supervisorAttachments'] ?? j['taskAttachments'],
    );
    final stuAttach = _attachList(
      j['studentAttachments'] ?? j['submissions'] ?? j['attachments'],
    );

    final isCompleted = j['isCompleted'] ?? j['is_completed'] ?? false;

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
    if (v is List) {
      return v.map((e) {
        if (e is Map) {
          return (e['id'] ?? e['userId'] ?? e['memberId'] ?? '').toString();
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  /// ✅ FIXED: filters out feedback-shaped entries that may have leaked
  /// into the attachments array from a backend serialization bug
  /// (Feedback rows mixed into the same collection as real file
  /// attachments). A real attachment has a non-empty fileUrl OR a
  /// name with a file extension. A feedback row typically has
  /// 'message'/'from'/'createdAt' keys and no fileUrl — if we see
  /// that shape without file-like evidence, we drop it.
  List<Map<String, String>>? _attachList(dynamic v) {
    if (v == null) return null;
    if (v is List && v.isEmpty) return [];
    if (v is List) {
      return v
          .map<Map<String, String>?>((e) {
            if (e is! Map) return null;
            final m = e as Map<String, dynamic>;

            final name =
                (m['name'] ?? m['fileName'] ?? '').toString().trim();
            final fileUrl =
                (m['fileUrl'] ?? m['url'] ?? m['file_url'] ?? '')
                    .toString()
                    .trim();

            final hasFeedbackKeys = m.containsKey('message') ||
                m.containsKey('from') ||
                m.containsKey('feedbackId') ||
                m.containsKey('createdAt') ||
                m.containsKey('created_at');
            final looksLikeFile = fileUrl.isNotEmpty ||
                (name.isNotEmpty && name.contains('.'));

            if (hasFeedbackKeys && !looksLikeFile) {
              _log('⚠️ Dropped feedback-shaped entry from attachments: $m');
              return null;
            }
            if (name.isEmpty && fileUrl.isEmpty) return null;

            return {
              'name': name.isNotEmpty ? name : 'file',
              'type': (m['type'] ?? m['fileType'] ?? 'file').toString(),
              'fileUrl': fileUrl,
            };
          })
          .whereType<Map<String, String>>()
          .toList();
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