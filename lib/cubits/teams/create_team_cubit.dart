
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/services/team_api_service.dart';
import 'create_team_state.dart';

class CreateTeamCubit extends Cubit<CreateTeamState> {
  CreateTeamCubit() : super(CreateTeamInitial());

  final TeamApiService _teamApiService = TeamApiService();

  List<TeamMember> _allAssistants = [];
  List<TeamMember> _allMembers = [];
  List<TeamMember> _selectedAssistants = [];
  List<TeamMember> _selectedMembers = [];
  
  TeamModel? _createdTeam;
  TeamModel? get createdTeam => _createdTeam;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadUsersFromFirebase() async {
    if (isClosed) return;
    emit(UsersLoading());
    
    try {
      final querySnapshot = await _firestore.collection('users').get();
      if (isClosed) return;
      
      _allAssistants = [];
      _allMembers = [];
      
      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        final user = UserModel.fromMap(doc.id, userData);
        
        final teamMember = TeamMember(
          id: user.uid,
          name: user.fullName,
          role: user.track,
          position: user.position,
          photoUrl: user.photoUrl,
          isSelected: false,
          isAlreadyInTeam: false,
        );
        
        if (user.role == UserRole.assistant) {
          _allAssistants.add(teamMember);
        } else if (user.role == UserRole.user) {
          _allMembers.add(teamMember);
        }
      }
      
      if (isClosed) return;
      
      emit(UsersSearchLoaded(
        assistants: _allAssistants,
        members: _allMembers,
        studentsAlreadyInTeams: {},
      ));
      
      print('✅ Loaded ${_allAssistants.length} assistants and ${_allMembers.length} students');
      
    } catch (e) {
      print('❌ Error loading users: $e');
      if (!isClosed) {
        emit(CreateTeamError(message: 'Failed to load users: $e'));
      }
    }
  }

  void searchUsers(String query) {
    if (isClosed) return;
    
    if (_allAssistants.isEmpty && _allMembers.isEmpty) {
      return;
    }
    
    emit(UsersSearchLoading());

    final lowerQuery = query.toLowerCase();

    final filteredAssistants = _allAssistants
        .where((a) => a.name.toLowerCase().contains(lowerQuery))
        .map((a) => a.copyWith(isSelected: _selectedAssistants.any((s) => s.id == a.id)))
        .toList();

    final filteredMembers = _allMembers
        .where((m) => m.name.toLowerCase().contains(lowerQuery))
        .map((m) => m.copyWith(isSelected: _selectedMembers.any((s) => s.id == m.id)))
        .toList();

    if (isClosed) return;
    
    emit(UsersSearchLoaded(
      assistants: filteredAssistants,
      members: filteredMembers,
      studentsAlreadyInTeams: {},
    ));
  }

  void toggleAssistant(TeamMember assistant) {
    if (isClosed) return;
    
    final isSelected = _selectedAssistants.any((a) => a.id == assistant.id);
    
    if (isSelected) {
      _selectedAssistants.removeWhere((a) => a.id == assistant.id);
    } else {
      _selectedAssistants.add(assistant);
    }

    emit(AssistantToggled(
      selectedAssistants: List.from(_selectedAssistants),
      selectedMembers: List.from(_selectedMembers),
    ));
    
    _refreshSearchResults();
  }

  void toggleMember(TeamMember member) {
    if (isClosed) return;
    
    final isSelected = _selectedMembers.any((m) => m.id == member.id);
    
    if (isSelected) {
      _selectedMembers.removeWhere((m) => m.id == member.id);
    } else {
      _selectedMembers.add(member);
    }

    emit(MemberToggled(
      selectedAssistants: List.from(_selectedAssistants),
      selectedMembers: List.from(_selectedMembers),
    ));
    
    _refreshSearchResults();
  }

  void _refreshSearchResults() {
    if (isClosed) return;
    
    emit(UsersSearchLoaded(
      assistants: _allAssistants.map((a) {
        return a.copyWith(isSelected: _selectedAssistants.any((s) => s.id == a.id));
      }).toList(),
      members: _allMembers.map((m) {
        return m.copyWith(isSelected: _selectedMembers.any((s) => s.id == m.id));
      }).toList(),
      studentsAlreadyInTeams: {},
    ));
  }

  Future<void> createTeam({
    required String teamName,
    required String projectName,
    required String description,
    required String supervisorId,
    required String supervisorName,
  }) async {
    if (isClosed) return;
    emit(CreateTeamLoading());

    try {
      if (teamName.trim().isEmpty) {
        emit(CreateTeamError(message: 'Team name is required'));
        return;
      }

      final allMemberIds = <String>[];
      for (var assistant in _selectedAssistants) {
        allMemberIds.add(assistant.id);
      }
      for (var member in _selectedMembers) {
        allMemberIds.add(member.id);
      }

      print('✅ Creating team via backend: $teamName');
      print('   Total members: ${allMemberIds.length}');

      final result = await _teamApiService.createTeamWithResponse(
        name: teamName.trim(),
        projectName: projectName.trim().isEmpty ? null : projectName.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        supervisorId: supervisorId,
        supervisorName: supervisorName,
        memberIds: allMemberIds,
        assistants: _selectedAssistants,
        members: _selectedMembers,
      );

      if (result != null) {
        final team = result['team'] as TeamModel;
        final warning = result['warning'] as String?;
        
        _createdTeam = team;
        
        print('✅ Team created with ID: ${team.id}');
        
        if (warning != null && warning.isNotEmpty) {
          print('⚠️ Backend warning: $warning');
          if (!isClosed) {
            emit(CreateTeamWarning(message: warning));
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        print('✅ Team created successfully with ID: ${_createdTeam!.id}');
        
        if (!isClosed) {
          emit(TeamCreated(teamId: _createdTeam!.id));
        }
      } else {
        emit(CreateTeamError(message: 'Failed to create team. Please try again.'));
      }
      
    } catch (e) {
      print("❌ Team creation failed: $e");
      if (!isClosed) {
        emit(CreateTeamError(message: 'Failed to create team: $e'));
      }
    }
  }

  void reset() {
    if (isClosed) return;
    
    _selectedAssistants = [];
    _selectedMembers = [];
    _allAssistants = [];
    _allMembers = [];
    _createdTeam = null;
    emit(CreateTeamInitial());
  }

  List<TeamMember> getSelectedAssistants() => List.from(_selectedAssistants);
  List<TeamMember> getSelectedMembers() => List.from(_selectedMembers);
  int getSelectedAssistantsCount() => _selectedAssistants.length;
  int getSelectedMembersCount() => _selectedMembers.length;
}