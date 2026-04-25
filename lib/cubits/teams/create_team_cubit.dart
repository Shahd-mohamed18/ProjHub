

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

  // Data
  List<TeamMember> _allAssistants = [];
  List<TeamMember> _allMembers = [];
  List<TeamMember> _selectedAssistants = [];
  List<TeamMember> _selectedMembers = [];
  
  TeamModel? _createdTeam;
  TeamModel? get createdTeam => _createdTeam;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ جلب المستخدمين من Firebase باستخدام UserModel
  Future<void> loadUsersFromFirebase() async {
    emit(UsersLoading());
    
    try {
      final querySnapshot = await _firestore.collection('users').get();
      
      _allAssistants = [];
      _allMembers = [];
      
      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        // ✅ استخدام UserModel المصمم بشكل صحيح
        final user = UserModel.fromMap(doc.id, userData);
        
        final teamMember = TeamMember(
          id: user.uid,
          name: user.fullName,
          role: user.track,      // ✅ الطالب: التخصص (Flutter, Backend, AI)
          position: user.position, // ✅ المعيد: المنصب (Teaching Assistant)
          photoUrl: user.photoUrl,
        );
        
        // تصنيف المستخدمين حسب دورهم
        if (user.role == UserRole.assistant) {
          _allAssistants.add(teamMember);
        } else if (user.role == UserRole.user) {
          _allMembers.add(teamMember);
        }
        // تجاهل المشرفين لأنهم لا يضافون كأعضاء في الفريق
      }
      
      emit(UsersSearchLoaded(
        assistants: _allAssistants,
        members: _allMembers,
      ));
      
      print('✅ Loaded ${_allAssistants.length} assistants and ${_allMembers.length} students');
      
    } catch (e) {
      print('❌ Error loading users: $e');
      emit(CreateTeamError(message: 'Failed to load users: $e'));
    }
  }

  // البحث في المستخدمين
  void searchUsers(String query) {
    if (_allAssistants.isEmpty && _allMembers.isEmpty) {
      return;
    }
    
    emit(UsersSearchLoading());

    Future.delayed(const Duration(milliseconds: 300), () {
      final lowerQuery = query.toLowerCase();

      final filteredAssistants = _allAssistants
          .where((a) => a.name.toLowerCase().contains(lowerQuery))
          .map((a) {
            final isSelected = _selectedAssistants.any((s) => s.id == a.id);
            return a.copyWith(isSelected: isSelected);
          }).toList();

      final filteredMembers = _allMembers
          .where((m) => m.name.toLowerCase().contains(lowerQuery))
          .map((m) {
            final isSelected = _selectedMembers.any((s) => s.id == m.id);
            return m.copyWith(isSelected: isSelected);
          }).toList();

      emit(UsersSearchLoaded(
        assistants: filteredAssistants,
        members: filteredMembers,
      ));
    });
  }

  // اختيار أو إلغاء اختيار معيد
  void toggleAssistant(TeamMember assistant) {
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

  // اختيار أو إلغاء اختيار طالب
  void toggleMember(TeamMember member) {
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

  // تحديث نتائج البحث بعد التحديد
  void _refreshSearchResults() {
    emit(UsersSearchLoaded(
      assistants: _allAssistants.map((a) {
        return a.copyWith(isSelected: _selectedAssistants.any((s) => s.id == a.id));
      }).toList(),
      members: _allMembers.map((m) {
        return m.copyWith(isSelected: _selectedMembers.any((s) => s.id == m.id));
      }).toList(),
    ));
  }

  // ✅ إنشاء الفريق
  Future<void> createTeam({
    required String teamName,
    required String projectName,
    required String description,
    required String supervisorId,
    required String supervisorName,
  }) async {
    emit(CreateTeamLoading());

    try {
      if (teamName.trim().isEmpty) {
        emit(CreateTeamError(message: 'Team name is required'));
        return;
      }

      print('🚀 Creating team: $teamName');
      print('   Assistants: ${_selectedAssistants.length}');
      print('   Members: ${_selectedMembers.length}');

      final backendTeam = await _teamApiService.createTeam(
        name: teamName.trim(),
        projectName: projectName.trim().isEmpty ? null : projectName.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        supervisorId: supervisorId,
        supervisorName: supervisorName,
        assistants: _selectedAssistants,
        members: _selectedMembers,
      );

      if (backendTeam != null) {
        _createdTeam = backendTeam;
        print('✅ Team created successfully with ID: ${backendTeam.id}');
        emit(TeamCreated(teamId: _createdTeam!.id));
      } else {
        print('❌ Backend failed to create team');
        emit(CreateTeamError(message: 'Failed to create team. Please try again.'));
      }
    } catch (e, stack) {
      print("❌ Team creation failed: $e");
      print(stack);
      emit(CreateTeamError(message: 'Failed to create team: $e'));
    }
  }

  // إعادة تعيين الحالة
  void reset() {
    _selectedAssistants = [];
    _selectedMembers = [];
    _allAssistants = [];
    _allMembers = [];
    _createdTeam = null;
    emit(CreateTeamInitial());
  }

  // جلب قائمة المختارين
  List<TeamMember> getSelectedAssistants() => List.from(_selectedAssistants);
  List<TeamMember> getSelectedMembers() => List.from(_selectedMembers);
  int getSelectedAssistantsCount() => _selectedAssistants.length;
  int getSelectedMembersCount() => _selectedMembers.length;
}