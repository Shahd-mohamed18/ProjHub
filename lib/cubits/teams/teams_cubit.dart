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

  // تحميل الفرق حسب صلاحية المستخدم
  void loadTeamsForUser(String userId, UserRole userRole) {
    emit(TeamsLoading());

    try {
      print('📋 Loading teams for user: $userId, role: $userRole');

      _teamApiService
          .getMyTeams(userId)
          .then((backendTeams) {
            if (backendTeams.isNotEmpty) {
              _teams.clear();
              _teams.addAll(backendTeams);
              print('📋 Loaded ${_teams.length} teams from backend');
            } else if (_teams.isEmpty) {
              print('📋 No backend teams, using mock data');
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
            print('⚠️ Error loading teams from backend: $e');
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

  // إضافة فريق جديد
  void addTeam(TeamModel team) {
    print('➕ Adding team: ${team.name}');
    _teams.add(team);
    emit(TeamsLoaded(teams: List.from(_teams)));
  }

  // حذف فريق
  Future<bool> deleteTeam(String teamId) async {
    try {
      print('🗑️ Deleting team: $teamId');

      final backendSuccess = await _teamApiService.deleteTeam(teamId);

      _teams.removeWhere((team) => team.id == teamId);
      emit(TeamsLoaded(teams: List.from(_teams)));

      if (backendSuccess) {
        print('✅ Team deleted from backend successfully');
      } else {
        print('⚠️ Team deleted locally only (backend failed)');
      }

      return true;
    } catch (e) {
      print('❌ Error deleting team: $e');
      _teams.removeWhere((team) => team.id == teamId);
      emit(TeamsLoaded(teams: List.from(_teams)));
      return false;
    }
  }

  // تحديث فريق
  void updateTeam(TeamModel updatedTeam) {
    final index = _teams.indexWhere((team) => team.id == updatedTeam.id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      emit(TeamsLoaded(teams: List.from(_teams)));
    }
  }

  // ✅ إضافة أعضاء جدد للفريق (من Firebase)
  Future<bool> addMembersToTeam({
    required String teamId,
    required List<TeamMember> newMembers,
  }) async {
    try {
      print('➕ Adding ${newMembers.length} members to team: $teamId');

      // جمع IDs الأعضاء الجدد
      final memberIds = newMembers.map((m) => m.id).toList();

      // استدعاء الـ API
      final success = await _teamApiService.addMembersToTeam(
        teamId: teamId,
        memberIds: memberIds,
      );

      if (success) {
        // تحديث القائمة المحلية
        final teamIndex = _teams.indexWhere((team) => team.id == teamId);
        if (teamIndex != -1) {
          final updatedTeam = _teams[teamIndex].copyWith(
            members: [..._teams[teamIndex].members, ...newMembers],
          );
          _teams[teamIndex] = updatedTeam;
        }

        emit(TeamsLoaded(teams: List.from(_teams)));
        print('✅ Members added successfully and local state updated');
        return true;
      } else {
        print('⚠️ Failed to add members to backend');
        return false;
      }
    } catch (e) {
      print('❌ Error adding members to team: $e');
      return false;
    }
  }

  // ✅ جلب الطلاب من Firebase فقط (غير المعيدين)
  // في TeamsCubit - تعديل دالة جلب الطلاب
  // في teams_cubit.dart - استبدال دالة getStudentsFromFirebase فقط
  Future<List<TeamMember>> getStudentsFromFirebase() async {
    try {
      print('📤 Fetching all users from Firebase...');

      final querySnapshot = await _firestore.collection('users').get();
      final List<TeamMember> users = [];

      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        // ✅ استخدام UserModel.fromMap
        final user = UserModel.fromMap(doc.id, userData);

        users.add(
          TeamMember(
            id: user.uid,
            name: user.fullName,
            role: user.track, // ✅ التخصص للطلاب
            position: user.position, // ✅ المنصب للمعيدين
            photoUrl: user.photoUrl,
            isSelected: false,
          ),
        );
      }

      print('✅ Found ${users.length} users from Firebase');
      return users;
    } catch (e) {
      print('❌ Error fetching users from Firebase: $e');
      return [];
    }
  }

  // Mock data
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
          TeamMember(
            id: 'a2',
            name: 'Mohamed Hassan',
            position: 'Lab Assistant',
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
          TeamMember(
            id: 'a2',
            name: 'Mohamed Hassan',
            position: 'Lab Assistant',
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
