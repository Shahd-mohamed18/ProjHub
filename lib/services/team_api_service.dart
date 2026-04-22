import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onboard/models/TeamModels/create_team_request.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamApiService {
  static const String baseUrl = 'https://projecthubb.runasp.net';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إنشاء فريق جديد
  Future<TeamModel?> createTeam({
    required String name,
    required String? projectName,
    required String? description,
    required String supervisorId,
    required String supervisorName,
    required List<TeamMember> assistants,
    required List<TeamMember> members,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/create');

      final List<String> memberIds = [];

      for (var assistant in assistants) {
        memberIds.add(assistant.id);
      }
      for (var member in members) {
        memberIds.add(member.id);
      }

      final Map<String, dynamic> requestBody = {
        'name': name,
        'supervisorId': supervisorId,
        'memberIds': memberIds,
      };

      if (projectName != null && projectName.isNotEmpty) {
        requestBody['projectName'] = projectName;
      }
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }

      print('📤 Creating team on backend:');
      print('   URL: $url');
      print('   Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        TeamModel? createdTeam;
        try {
          final responseData = jsonDecode(response.body);
          final teamId =
              responseData['id']?.toString() ??
              responseData['teamId']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString();

          createdTeam = TeamModel(
            id: teamId,
            name: name,
            projectName: projectName,
            description: description,
            supervisorId: supervisorId,
            supervisorName: supervisorName,
            assistants: assistants,
            members: members,
            createdAt: DateTime.now(),
            activeProjects: 1,
          );
        } catch (e) {
          print('⚠️ Could not parse response, but status code was success: $e');
          createdTeam = TeamModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            projectName: projectName,
            description: description,
            supervisorId: supervisorId,
            supervisorName: supervisorName,
            assistants: assistants,
            members: members,
            createdAt: DateTime.now(),
            activeProjects: 1,
          );
        }

        print('✅ Team created successfully on backend!');
        return createdTeam;
      } else {
        print('❌ Backend error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Failed to create team on backend: $e');
      return null;
    }
  }

  // جلب فرق المستخدم من الباك اند
  Future<List<TeamModel>> getMyTeams(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/my-teams/$userId');

      print('📤 Fetching teams for user: $userId');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final List<dynamic> teamsData = jsonDecode(response.body);
          final List<TeamModel> teams = [];

          for (var teamData in teamsData) {
            final assistantsData = teamData['assistants'] as List? ?? [];
            final membersData = teamData['members'] as List? ?? [];

            final assistants = assistantsData
                .map(
                  (a) => TeamMember(
                    id: a['id']?.toString() ?? '',
                    name: a['name'] ?? '',
                    position: a['position'],
                    photoUrl: a['photoUrl'],
                  ),
                )
                .toList();

            final members = membersData
                .map(
                  (m) => TeamMember(
                    id: m['id']?.toString() ?? '',
                    name: m['name'] ?? '',
                    role: m['role'],
                    photoUrl: m['photoUrl'],
                  ),
                )
                .toList();

            teams.add(
              TeamModel(
                id: teamData['id']?.toString() ?? '',
                name: teamData['name'] ?? '',
                projectName: teamData['projectName'],
                description: teamData['description'],
                supervisorId: teamData['supervisorId']?.toString() ?? '',
                supervisorName: teamData['supervisorName'],
                assistants: assistants,
                members: members,
                createdAt: teamData['createdAt'] != null
                    ? DateTime.parse(teamData['createdAt'])
                    : DateTime.now(),
                activeProjects: teamData['activeProjects'] ?? 1,
              ),
            );
          }

          return teams;
        } catch (e) {
          print('⚠️ Could not parse teams response: $e');
          return [];
        }
      } else {
        print('❌ Failed to fetch teams: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('⚠️ Error fetching teams: $e');
      return [];
    }
  }

  // جلب تفاصيل فريق معين
  Future<TeamModel?> getTeamDetails(String teamId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/$teamId/details');

      print('📤 Fetching team details for team: $teamId');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);

          final List<TeamMember> assistants = [];
          final assistantsData = data['assistants'] as List? ?? [];
          for (var a in assistantsData) {
            assistants.add(
              TeamMember(
                id: a['id']?.toString() ?? '',
                name: a['name'] ?? '',
                position: a['position'],
                photoUrl: a['photoUrl'],
              ),
            );
          }

          final List<TeamMember> members = [];
          final membersData = data['members'] as List? ?? [];
          for (var m in membersData) {
            members.add(
              TeamMember(
                id: m['id']?.toString() ?? '',
                name: m['name'] ?? '',
                role: m['role'],
                photoUrl: m['photoUrl'],
              ),
            );
          }

          return TeamModel(
            id: data['id']?.toString() ?? teamId,
            name: data['name'] ?? '',
            projectName: data['projectName'],
            description: data['description'],
            supervisorId: data['supervisorId']?.toString() ?? '',
            supervisorName: data['supervisorName'],
            assistants: assistants,
            members: members,
            createdAt: data['createdAt'] != null
                ? DateTime.parse(data['createdAt'])
                : DateTime.now(),
            activeProjects: data['activeProjects'] ?? 1,
          );
        } catch (e) {
          print('⚠️ Could not parse team details: $e');
          return null;
        }
      } else {
        print('❌ Failed to fetch team details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error fetching team details: $e');
      return null;
    }
  }

  // حذف فريق
  Future<bool> deleteTeam(String teamId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/$teamId');

      print('📤 Deleting team: $teamId');

      final response = await http.delete(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Team deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete team: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error deleting team: $e');
      return false;
    }
  }

  // إضافة أعضاء جدد للفريق (teamId كـ string)
  Future<bool> addMembersToTeam({
    required String teamId,
    required List<String> memberIds,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/add-members');

      final requestBody = {
        'teamId': teamId, // ✅ string مباشرة
        'memberIds': memberIds,
      };

      print('📤 Adding members to team:');
      print('   URL: $url');
      print('   Team ID: $teamId');
      print('   Members count: ${memberIds.length}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Members added successfully');
        return true;
      } else {
        print('❌ Failed to add members: ${response.statusCode}');
        print('   Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error adding members to team: $e');
      return false;
    }
  }

  // إضافة أعضاء جدد للفريق
  
}
