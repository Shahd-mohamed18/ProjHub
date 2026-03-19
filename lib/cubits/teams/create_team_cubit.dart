
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:onboard/models/TeamModels/team_member.dart';
// import 'package:onboard/models/TeamModels/team_model.dart';
// import 'package:onboard/models/user_model.dart';
// import 'create_team_state.dart';

// class CreateTeamCubit extends Cubit<CreateTeamState> {
//   CreateTeamCubit() : super(CreateTeamInitial());

//   // Data
//   List<TeamMember> _allAssistants = [];
//   List<TeamMember> _allMembers = [];
//   List<TeamMember> _selectedAssistants = [];
//   List<TeamMember> _selectedMembers = [];
  
//   TeamModel? _createdTeam;
//   TeamModel? get createdTeam => _createdTeam;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // جلب المستخدمين من Firebase
//   Future<void> loadUsersFromFirebase() async {
//     emit(UsersLoading());
    
//     try {
//       final querySnapshot = await _firestore.collection('users').get();
      
//       _allAssistants = [];
//       _allMembers = [];
      
//       for (var doc in querySnapshot.docs) {
//         final userData = doc.data();
//         final user = UserModel.fromMap(doc.id, userData);
        
//         final teamMember = TeamMember(
//           id: user.uid,
//           name: user.fullName,
//           role: user.role == UserRole.user ? user.track : null,
//           position: user.role != UserRole.user ? user.position : null,
//         );
        
//         if (user.role == UserRole.assistant) {
//           _allAssistants.add(teamMember);
//         } else if (user.role == UserRole.user) {
//           _allMembers.add(teamMember);
//         }
//       }
      
//       emit(UsersSearchLoaded(
//         assistants: _allAssistants,
//         members: _allMembers,
//       ));
      
//     } catch (e) {
//       emit(CreateTeamError(message: 'Failed to load users: $e'));
//     }
//   }

//   // البحث في المستخدمين
//   void searchUsers(String query) {
//     if (_allAssistants.isEmpty && _allMembers.isEmpty) {
//       return;
//     }
    
//     emit(UsersSearchLoading());

//     Future.delayed(const Duration(milliseconds: 300), () {
//       final lowerQuery = query.toLowerCase();

//       final filteredAssistants = _allAssistants
//           .where((a) => a.name.toLowerCase().contains(lowerQuery))
//           .map((a) {
//             final isSelected = _selectedAssistants.any((s) => s.id == a.id);
//             return a.copyWith(isSelected: isSelected);
//           }).toList();

//       final filteredMembers = _allMembers
//           .where((m) => m.name.toLowerCase().contains(lowerQuery))
//           .map((m) {
//             final isSelected = _selectedMembers.any((s) => s.id == m.id);
//             return m.copyWith(isSelected: isSelected);
//           }).toList();

//       emit(UsersSearchLoaded(
//         assistants: filteredAssistants,
//         members: filteredMembers,
//       ));
//     });
//   }

//   // اختيار أو إلغاء اختيار معيد
//   void toggleAssistant(TeamMember assistant) {
//     final isSelected = _selectedAssistants.any((a) => a.id == assistant.id);
    
//     if (isSelected) {
//       _selectedAssistants.removeWhere((a) => a.id == assistant.id);
//     } else {
//       _selectedAssistants.add(assistant);
//     }

//     emit(AssistantToggled(
//       selectedAssistants: List.from(_selectedAssistants),
//       selectedMembers: List.from(_selectedMembers),
//     ));
    
//     _refreshSearchResults();
//   }

//   // اختيار أو إلغاء اختيار طالب
//   void toggleMember(TeamMember member) {
//     final isSelected = _selectedMembers.any((m) => m.id == member.id);
    
//     if (isSelected) {
//       _selectedMembers.removeWhere((m) => m.id == member.id);
//     } else {
//       _selectedMembers.add(member);
//     }

//     emit(MemberToggled(
//       selectedAssistants: List.from(_selectedAssistants),
//       selectedMembers: List.from(_selectedMembers),
//     ));
    
//     _refreshSearchResults();
//   }

//   // تحديث نتائج البحث بعد التحديد
//   void _refreshSearchResults() {
//     emit(UsersSearchLoaded(
//       assistants: _allAssistants.map((a) {
//         return a.copyWith(isSelected: _selectedAssistants.any((s) => s.id == a.id));
//       }).toList(),
//       members: _allMembers.map((m) {
//         return m.copyWith(isSelected: _selectedMembers.any((s) => s.id == m.id));
//       }).toList(),
//     ));
//   }

//   // إنشاء الفريق
//   Future<void> createTeam({
//     required String teamName,
//     required String projectName,
//     required String description,
//     required String supervisorId,
//     required String supervisorName,
//   }) async {
//     emit(CreateTeamLoading());

//     try {
//       if (teamName.trim().isEmpty) {
//         emit(CreateTeamError(message: 'Team name is required'));
//         return;
//       }

//       // محاكاة طلب API
//       await Future.delayed(const Duration(seconds: 1));

//       // إنشاء team object جديد
//       _createdTeam = TeamModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         name: teamName.trim(),
//         projectName: projectName.trim().isEmpty ? null : projectName.trim(),
//         description: description.trim().isEmpty ? null : description.trim(),
//         supervisorId: supervisorId,
//         supervisorName: supervisorName,
//         assistants: List.from(_selectedAssistants),
//         members: List.from(_selectedMembers),
//         createdAt: DateTime.now(),
//         activeProjects: 1,
//       );

//       print('✅ Team created locally: ${_createdTeam!.name}');
//       print('📦 Team data ready for .NET backend:');
//       print({
//         'name': teamName,
//         'projectName': projectName,
//         'description': description,
//         'supervisorId': supervisorId,
//         'assistantIds': _selectedAssistants.map((a) => a.id).toList(),
//         'memberIds': _selectedMembers.map((m) => m.id).toList(),
//         'assistantNames': _selectedAssistants.map((a) => a.name).toList(),
//         'memberNames': _selectedMembers.map((m) => m.name).toList(),
//         'createdAt': DateTime.now().toIso8601String(),
//       });

//       emit(TeamCreated(teamId: _createdTeam!.id));
//     } catch (e, stack) {
//       print("Team creation failed: $e");
//       print(stack);
//       emit(CreateTeamError(message: 'Failed to create team: $e'));
//     }
//   }

//   // إعادة تعيين الحالة
//   void reset() {
//     _selectedAssistants = [];
//     _selectedMembers = [];
//     _allAssistants = [];
//     _allMembers = [];
//     _createdTeam = null;
//     emit(CreateTeamInitial());
//   }

//   // جلب قائمة المختارين
//   List<TeamMember> getSelectedAssistants() => List.from(_selectedAssistants);
//   List<TeamMember> getSelectedMembers() => List.from(_selectedMembers);
//   int getSelectedAssistantsCount() => _selectedAssistants.length;
//   int getSelectedMembersCount() => _selectedMembers.length;
// }


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/user_model.dart';
import 'create_team_state.dart';

class CreateTeamCubit extends Cubit<CreateTeamState> {
  CreateTeamCubit() : super(CreateTeamInitial());

  // Data
  List<TeamMember> _allAssistants = [];
  List<TeamMember> _allMembers = [];
  List<TeamMember> _selectedAssistants = [];
  List<TeamMember> _selectedMembers = [];
  
  TeamModel? _createdTeam;
  TeamModel? get createdTeam => _createdTeam;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب المستخدمين من Firebase
  Future<void> loadUsersFromFirebase() async {
    emit(UsersLoading());
    
    try {
      final querySnapshot = await _firestore.collection('users').get();
      
      _allAssistants = [];
      _allMembers = [];
      
      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        final user = UserModel.fromMap(doc.id, userData);
        
        final teamMember = TeamMember(
          id: user.uid,
          name: user.fullName,
          role: user.role == UserRole.user ? user.track : null,
          position: user.role != UserRole.user ? user.position : null,
          photoUrl: user.photoUrl, // ✅ إضافة الصورة هنا
        );
        
        if (user.role == UserRole.assistant) {
          _allAssistants.add(teamMember);
        } else if (user.role == UserRole.user) {
          _allMembers.add(teamMember);
        }
      }
      
      emit(UsersSearchLoaded(
        assistants: _allAssistants,
        members: _allMembers,
      ));
      
    } catch (e) {
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

  // إنشاء الفريق (محلياً للـ .NET backend)
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

      // محاكاة تأخير
      await Future.delayed(const Duration(seconds: 1));

      // إنشاء team object جديد
      _createdTeam = TeamModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: teamName.trim(),
        projectName: projectName.trim().isEmpty ? null : projectName.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        supervisorId: supervisorId,
        supervisorName: supervisorName,
        assistants: List.from(_selectedAssistants),
        members: List.from(_selectedMembers),
        createdAt: DateTime.now(),
        activeProjects: 1,
      );

      print('✅ Team created locally: ${_createdTeam!.name}');
      print('📦 Team data ready for .NET backend:');
      print({
        'id': _createdTeam!.id,
        'name': teamName,
        'projectName': projectName,
        'description': description,
        'supervisorId': supervisorId,
        'supervisorName': supervisorName,
        'assistants': _selectedAssistants.map((a) => {
          'id': a.id, 
          'name': a.name, 
          'position': a.position,
          'photoUrl': a.photoUrl, // ✅ إضافة الصورة
        }).toList(),
        'members': _selectedMembers.map((m) => {
          'id': m.id, 
          'name': m.name, 
          'role': m.role,
          'photoUrl': m.photoUrl, // ✅ إضافة الصورة
        }).toList(),
        'assistantIds': _selectedAssistants.map((a) => a.id).toList(),
        'memberIds': _selectedMembers.map((m) => m.id).toList(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      emit(TeamCreated(teamId: _createdTeam!.id));
    } catch (e, stack) {
      print("Team creation failed: $e");
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