
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/TeamModels/team_model.dart';

class TeamApiService {
  static const String baseUrl = 'https://projecthubb.runasp.net';

  // إنشاء فريق مع استقبال الـ Response كامل
  Future<Map<String, dynamic>?> createTeamWithResponse({
    required String name,
    required String? projectName,
    required String? description,
    required String supervisorId,
    required String supervisorName,
    required List<String> memberIds,
    required List<TeamMember> assistants,
    required List<TeamMember> members,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/create');

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

      print('----- Creating team on backend:');
      print('   Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('----- Response status: ${response.statusCode}');
      print('----- Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        
        String? warning;
        if (responseData['warning'] != null) {
          warning = responseData['warning'].toString();
        }
        
        // ✅ الحصول على ID الفريق من الباك اند
        String? teamId;
        if (responseData['teamId'] != null) {
          teamId = responseData['teamId'].toString();
        } else if (responseData['id'] != null) {
          teamId = responseData['id'].toString();
        } else {
          // إذا لم يرجع الباك اند الـ ID، نجلب الفريق من getMyTeams
          print('⚠️ No team ID in response, fetching from getMyTeams...');
          final teams = await getMyTeams(supervisorId);
          final createdTeam = teams.firstWhere(
            (t) => t.name == name,
            orElse: () => teams.firstWhere(
              (t) => t.projectName == projectName,
              orElse: () => TeamModel(
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
              ),
            ),
          );
          teamId = createdTeam.id;
        }
        
        final team = TeamModel(
          id: teamId!,
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
        
        print('------------- Team created successfully with ID: ${team.id}');
        
        return {
          'team': team,
          'warning': warning,
          'success': responseData['success'] ?? true,
        };
      } else {
        print('------------ Backend error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('------------ Failed to create team on backend: $e');
      return null;
    }
  }

  // إضافة أعضاء إلى فريق مع استقبال الـ Response كامل
  Future<Map<String, dynamic>> addMembersToTeamWithResponse({
    required String teamId,
    required List<String> memberIds,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/add-members');

      final requestBody = {'teamId': teamId, 'memberIds': memberIds};

      print('----- Adding members to team:');
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

      print('----- Response status: ${response.statusCode}');
      print('----- Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        
        String? warning;
        String? message;
        
        if (responseData['warning'] != null) {
          warning = responseData['warning'].toString();
        }
        if (responseData['message'] != null) {
          message = responseData['message'].toString();
        }
        
        final success = responseData['success'] ?? false;
        
        return {
          'success': success,
          'warning': warning,
          'message': message,
        };
      } else {
        print('----- Failed to add members: ${response.statusCode}');
        print('   Response: ${response.body}');
        return {
          'success': false,
          'warning': null,
          'message': null,
        };
      }
    } catch (e) {
      print('-----Error adding members to team: $e');
      return {
        'success': false,
        'warning': null,
        'message': null,
      };
    }
  }

  Future<bool> addMembersToTeam({
    required String teamId,
    required List<String> memberIds,
  }) async {
    final result = await addMembersToTeamWithResponse(
      teamId: teamId,
      memberIds: memberIds,
    );
    return result['success'] ?? false;
  }

  Future<TeamModel?> createTeam({
    required String name,
    required String? projectName,
    required String? description,
    required String supervisorId,
    required String supervisorName,
    required List<TeamMember> assistants,
    required List<TeamMember> members,
  }) async {
    final allMemberIds = <String>[];
    for (var assistant in assistants) {
      allMemberIds.add(assistant.id);
    }
    for (var member in members) {
      allMemberIds.add(member.id);
    }
    
    final result = await createTeamWithResponse(
      name: name,
      projectName: projectName,
      description: description,
      supervisorId: supervisorId,
      supervisorName: supervisorName,
      memberIds: allMemberIds,
      assistants: assistants,
      members: members,
    );
    
    return result != null ? result['team'] as TeamModel : null;
  }

  Future<List<TeamModel>> getMyTeams(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/my-teams/$userId');
      print('------------ Fetching teams for user: $userId');
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
            final assistants = assistantsData.map((a) => TeamMember(
              id: a['id']?.toString() ?? '',
              name: a['name'] ?? '',
              position: a['position'] ?? a['role'],
              photoUrl: a['photoUrl'],
            )).toList();
            final members = membersData.map((m) => TeamMember(
              id: m['id']?.toString() ?? '',
              name: m['name'] ?? '',
              role: m['role'] ?? m['track'],
              photoUrl: m['photoUrl'],
            )).toList();
            teams.add(TeamModel(
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
            ));
          }
          return teams;
        } catch (e) {
          print('------------ Could not parse teams response: $e');
          return [];
        }
      } else {
        print('------------ Failed to fetch teams: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('------------ Error fetching teams: $e');
      return [];
    }
  }

  Future<TeamModel?> getTeamDetails(String teamId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/$teamId/details');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final assistantsData = data['assistants'] as List? ?? [];
        final membersData = data['members'] as List? ?? [];
        final assistants = assistantsData.map((a) => TeamMember(
          id: a['id']?.toString() ?? '',
          name: a['name'] ?? '',
          position: a['position'] ?? a['role'],
          photoUrl: a['photoUrl'],
        )).toList();
        final members = membersData.map((m) => TeamMember(
          id: m['id']?.toString() ?? '',
          name: m['name'] ?? '',
          role: m['role'] ?? m['track'],
          photoUrl: m['photoUrl'],
        )).toList();
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
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching team details: $e');
      return null;
    }
  }

  Future<bool> deleteTeam(String teamId) async {
    try {
      final url = Uri.parse('$baseUrl/api/Teams/$teamId');
      final response = await http.delete(
        url,
        headers: {'Accept': 'application/json'},
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error deleting team: $e');
      return false;
    }
  }
}