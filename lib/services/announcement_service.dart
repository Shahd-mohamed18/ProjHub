// lib/services/announcement_service.dart

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:onboard/models/AnnouncementModels/announcement_model.dart';

class AnnouncementService {
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

  void _log(String m) => print('[AnnouncementService] $m');

  Future<List<AnnouncementModel>> getAnnouncements({
    required int teamId,
    String? userId,
  }) async {
    final uid = userId ?? _uid ?? '';
    final result = await _fetchAnnouncements(teamId: teamId, uid: uid);
    if (result.isNotEmpty) return result;
    if (uid.isNotEmpty) {
      _log('Retrying without userId param…');
      return _fetchAnnouncements(teamId: teamId, uid: '');
    }
    return result;
  }

  Future<List<AnnouncementModel>> _fetchAnnouncements({
    required int teamId,
    required String uid,
  }) async {
    final uri = Uri.parse('$_base/api/Announcement/$teamId').replace(
      queryParameters: uid.isNotEmpty ? {'userId': uid} : null,
    );

    _log('GET $uri');
    try {
      final r = await http.get(uri, headers: await _headers());
      _log('${r.statusCode}  body=${r.body.length > 400 ? r.body.substring(0, 400) : r.body}');

      if (r.statusCode < 200 || r.statusCode >= 300) {
        _log('HTTP error ${r.statusCode}');
        return [];
      }

      if (r.body.trim().isEmpty) {
        _log('Empty response body');
        return [];
      }

      final decoded = jsonDecode(r.body);

      // حالة المصفوفة
      if (decoded is List) {
        return decoded
            .map((j) => AnnouncementModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      // حالة الكائن
      if (decoded is Map) {
        // 1️⃣ تحقق من وجود حقل data/announcements/items/result
        final list = decoded['data'] ??
            decoded['announcements'] ??
            decoded['items'] ??
            decoded['result'];
        if (list is List) {
          return list
              .map((j) => AnnouncementModel.fromJson(j as Map<String, dynamic>))
              .toList();
        }

        // 2️⃣ إذا لم يكن هناك قائمة، وتحقق مما إذا كان الكائن نفسه إعلاناً
        if (decoded.containsKey('id') && decoded.containsKey('message')) {
          return [AnnouncementModel.fromJson(Map<String, dynamic>.from(decoded))];
        }
      }

      _log('Unexpected response shape: ${decoded.runtimeType}');
      return [];
    } catch (e, st) {
      _log('_fetchAnnouncements error: $e\n$st');
      return [];
    }
  }

  // ── POST /api/Announcement ──────────────────────────────────────────────────
  Future<bool> createAnnouncement({
    required String message,
    String? meetingLink,
    required int teamId,
    required String supervisorId,
    required String supervisorName,
  }) async {
    final uri = Uri.parse('$_base/api/Announcement');
    final body = {
      'message': message,
      'meetingLink': meetingLink,
      'teamId': teamId,
      'supervisorId': supervisorId,
      'supervisorName': supervisorName,
    };

    _log('POST $uri  body=${jsonEncode(body)}');
    try {
      final r = await http.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(body),
      );
      _log('${r.statusCode}  ${r.body}');
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (e) {
      _log('createAnnouncement error: $e');
      return false;
    }
  }

  // ── DELETE /api/Announcement/{teamId} ───────────────────────────────────────
  Future<bool> deleteAnnouncements({
    required int teamId,
    required String supervisorId,
  }) async {
    final uri = Uri.parse('$_base/api/Announcement/$teamId').replace(
      queryParameters: {'supervisorId': supervisorId},
    );

    _log('DELETE $uri');
    try {
      final r = await http.delete(uri, headers: await _headers());
      _log('${r.statusCode}  ${r.body}');
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (e) {
      _log('deleteAnnouncements error: $e');
      return false;
    }
  }
}