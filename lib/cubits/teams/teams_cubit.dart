// lib/cubits/teams/teams_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/services/team_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit() : super(TeamsInitial());

  final TeamApiService _teamApiService = TeamApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<TeamModel> _teams = [];

  void loadTeamsForUser(String userId, UserRole userRole) {
    emit(TeamsLoading());

    try {
      print('---------- Loading teams for user: $userId, role: $userRole');

      _teamApiService
          .getMyTeams(userId)
          .then((backendTeams) {
            if (backendTeams.isNotEmpty) {
              _teams.clear();
              _teams.addAll(backendTeams);
              print('---------- Loaded ${_teams.length} teams from backend');
            } else if (_teams.isEmpty) {
              print('---------- No backend teams, using mock data');
              if (userRole == UserRole.supervisor) {
                _teams.addAll(_getMockTeamsForSupervisor(userId));
              } else if (userRole == UserRole.assistant) {
                _teams.addAll(_getMockTeamsForAssistant(userId));
              } else {
                _teams.addAll(_getMockTeamsForUser(userId));
              }
            }

            emit(TeamsLoaded(teams: List.from(_teams)));
          })
          .catchError((e) {
            print('---------- Error loading teams from backend: $e');
            if (_teams.isEmpty) {
              if (userRole == UserRole.supervisor) {
                _teams.addAll(_getMockTeamsForSupervisor(userId));
              } else if (userRole == UserRole.assistant) {
                _teams.addAll(_getMockTeamsForAssistant(userId));
              } else {
                _teams.addAll(_getMockTeamsForUser(userId));
              }
            }
            emit(TeamsLoaded(teams: List.from(_teams)));
          });
    } catch (e) {
      emit(TeamsError(message: 'Failed to load teams: $e'));
    }
  }

  void addTeam(TeamModel team) {
    print('---------- Adding team: ${team.name} (ID: ${team.id})');
    
    final existingIndex = _teams.indexWhere((t) => t.id == team.id);
    if (existingIndex != -1) {
      print('---------- Team already exists, updating instead');
      _teams[existingIndex] = team;
    } else {
      _teams.add(team);
    }
    
    emit(TeamsLoaded(teams: List.from(_teams)));
  }

  Future<bool> deleteTeam(String teamId) async {
    try {
      print('---------- Deleting team: $teamId');

      final backendSuccess = await _teamApiService.deleteTeam(teamId);

      _teams.removeWhere((team) => team.id == teamId);
      emit(TeamsLoaded(teams: List.from(_teams)));

      if (backendSuccess) {
        print('---------- Team deleted from backend successfully');
      } else {
        print('---------- Team deleted locally only (backend failed)');
      }

      return true;
    } catch (e) {
      print('---------- Error deleting team: $e');
      _teams.removeWhere((team) => team.id == teamId);
      emit(TeamsLoaded(teams: List.from(_teams)));
      return false;
    }
  }

  void updateTeam(TeamModel updatedTeam) {
    final index = _teams.indexWhere((team) => team.id == updatedTeam.id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      emit(TeamsLoaded(teams: List.from(_teams)));
    }
  }

 

    Future<bool> addMembersToTeam({
    required String teamId,
    required List<TeamMember> newMembers,
  }) async {
    try {
      print('---------- Adding ${newMembers.length} members to team: $teamId');
      
      final memberIds = newMembers.map((m) => m.id).toList();
      
      final result = await _teamApiService.addMembersToTeamWithResponse(
        teamId: teamId,
        memberIds: memberIds,
      );
      
      final success = result['success'] ?? false;
      final warning = result['warning'];
      final message = result['message'];
      
      if (success) {
        // ✅ التحقق من أنه تمت إضافة أعضاء فعلاً
        if (message != null && message.contains('Added 0 members')) {
          print('⚠️ No members were added: $message');
          emit(TeamMembersAddWarning(warning: message));
          return false;
        }
        
        if (warning != null && warning.isNotEmpty) {
          print('⚠️ Warning from backend: $warning');
          emit(TeamMembersAddWarning(warning: warning));
          return false;
        }
        
        // ✅ فقط هنا نحدث الـ UI المحلي (بعد التأكد من نجاح الإضافة)
        print('✅ Members added successfully');
        
        final teamIndex = _teams.indexWhere((team) => team.id == teamId);
        if (teamIndex != -1) {
          final updatedTeam = _teams[teamIndex].copyWith(
            members: [..._teams[teamIndex].members, ...newMembers],
          );
          _teams[teamIndex] = updatedTeam;
          emit(TeamsLoaded(teams: List.from(_teams)));
          print('---------- Local state updated');
        }
        
        return true;
      } else {
        print('---------- Failed to add members to backend');
        return false;
      }
    } catch (e) {
      print('---------- Error adding members to team: $e');
      return false;
    }
  }

  Future<List<TeamMember>> getStudentsFromFirebase() async {
    try {
      print('---------- Fetching all users from Firebase...');

      final querySnapshot = await _firestore.collection('users').get();
      final List<TeamMember> users = [];

      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        
        final user = UserModel.fromMap(doc.id, userData);

        users.add(
          TeamMember(
            id: user.uid,
            name: user.fullName,
            role: user.track, 
            position: user.position,
            photoUrl: user.photoUrl,
            isSelected: false,
          ),
        );
      }

      print('---------- Found ${users.length} users from Firebase');
      return users;
    } catch (e) {
      print('---------- Error fetching users from Firebase: $e');
      return [];
    }
  }

  List<TeamModel> _getMockTeamsForSupervisor(String supervisorId) {
    return [
      TeamModel(
        id: '1',
        name: 'Team A',
        projectName: 'ProjHub Project',
        description:
            'Building the next generation project management platform for modern teams',
        supervisorId: supervisorId,
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(
            id: 'a1',
            name: 'Alaa Nabil',
            position: 'Teaching Assistant',
            photoUrl: '',
          ),
        ],
        members: [
          TeamMember(
            id: 'm1',
            name: 'Marwa Mohamed',
            role: 'Team Lead(Flutter)',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm2',
            name: 'Faten Hesham',
            role: 'Designer',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm3',
            name: 'Aya Mosa',
            role: 'BackEnd Developer',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm4',
            name: 'Dalia Gamal',
            role: 'BackEnd Developer',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm5',
            name: 'Asmaa Elsaid',
            role: 'Flutter Developer',
            photoUrl: '',
          ),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
    ];
  }

  List<TeamModel> _getMockTeamsForAssistant(String assistantId) {
    return [
      TeamModel(
        id: '1',
        name: 'Team A',
        projectName: 'ProjHub Project',
        description:
            'Building the next generation project management platform for modern teams',
        supervisorId: 'sup1',
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(
            id: assistantId,
            name: 'Alaa Nabil',
            position: 'Teaching Assistant',
            photoUrl: '',
          ),
        ],
        members: [
          TeamMember(
            id: 'm1',
            name: 'Marwa Mohamed',
            role: 'Team Lead(Flutter)',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm2',
            name: 'Faten Hesham',
            role: 'Designer',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm3',
            name: 'Aya Mosa',
            role: 'BackEnd Developer',
            photoUrl: '',
          ),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
    ];
  }

  List<TeamModel> _getMockTeamsForUser(String userId) {
    return [
      TeamModel(
        id: '1',
        name: 'Team A',
        projectName: 'ProjHub Project',
        description: 'Building the next generation project management platform',
        supervisorId: 'sup1',
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(
            id: 'a1',
            name: 'Alaa Nabil',
            position: 'Teaching Assistant',
            photoUrl: '',
          ),
        ],
        members: [
          TeamMember(
            id: userId,
            name: 'Marwa Mohamed',
            role: 'Team Lead(Flutter)',
            photoUrl: '',
          ),
          TeamMember(
            id: 'm2',
            name: 'Faten Hesham',
            role: 'Designer',
            photoUrl: '',
          ),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
    ];
  }

  void clearTeams() {
    _teams.clear();
    emit(TeamsInitial());
  }
}