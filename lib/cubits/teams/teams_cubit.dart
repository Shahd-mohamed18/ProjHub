

// lib/cubits/teams/teams_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/user_model.dart';

class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit() : super(TeamsInitial());

  final List<TeamModel> _teams = [];

  // تحميل الفرق حسب صلاحية المستخدم
  void loadTeamsForUser(String userId, UserRole userRole) {
    emit(TeamsLoading());
    
    try {
      // لو القائمة فاضية، نضيف الفرق
      if (_teams.isEmpty) {
        print('📋 Loading teams for user: $userId, role: $userRole');
        
        if (userRole == UserRole.supervisor) {
          // للدكتور - كل الفرق اللي هو مشرف عليها
          _teams.addAll(_getMockTeamsForSupervisor(userId));
        } else if (userRole == UserRole.assistant) {
          // للمعيد - الفرق اللي هو مشارك فيها كمساعد
          _teams.addAll(_getMockTeamsForAssistant(userId));
        } else {
          // للمستخدم العادي - مش هنستخدمه دلوقتي
          _teams.addAll(_getMockTeamsForUser(userId));
        }
      } else {
        print('📋 Teams already loaded, count: ${_teams.length}');
      }
      
      emit(TeamsLoaded(teams: List.from(_teams)));
    } catch (e) {
      emit(TeamsError(message: 'Failed to load teams: $e'));
    }
  }

  // إضافة فريق جديد
  void addTeam(TeamModel team) {
    print('➕ Adding team: ${team.name}');
    print('Current teams count before: ${_teams.length}');
    
    _teams.add(team);
    
    print('Current teams count after: ${_teams.length}');
    print('All teams: ${_teams.map((t) => t.name).toList()}');
    
    emit(TeamsLoaded(teams: List.from(_teams)));
  }

  // حذف فريق
  void removeTeam(String teamId) {
    _teams.removeWhere((team) => team.id == teamId);
    emit(TeamsLoaded(teams: List.from(_teams)));
  }

  // تحديث فريق
  void updateTeam(TeamModel updatedTeam) {
    final index = _teams.indexWhere((team) => team.id == updatedTeam.id);
    if (index != -1) {
      _teams[index] = updatedTeam;
      emit(TeamsLoaded(teams: List.from(_teams)));
    }
  }

  // دالة مساعدة لجلب فرق الدكتور
  List<TeamModel> _getMockTeamsForSupervisor(String supervisorId) {
    return [
      TeamModel(
        id: '1',
        name: 'Team A',
        projectName: 'ProjHub Project',
        description: 'Building the next generation project management platform for modern teams',
        supervisorId: supervisorId,
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(id: 'a1', name: 'Alaa Nabil', position: 'Teaching Assistant', photoUrl: ''),
          TeamMember(id: 'a2', name: 'Mohamed Hassan', position: 'Lab Assistant', photoUrl: ''),
        ],
        members: [
          TeamMember(id: 'm1', name: 'Marwa Mohamed', role: 'Team Lead(Flutter)', photoUrl: ''),
          TeamMember(id: 'm2', name: 'Faten Hesham', role: 'Designer', photoUrl: ''),
          TeamMember(id: 'm3', name: 'Aya Mosa', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm4', name: 'Dalia Gamal', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm5', name: 'Asmaa Elsaid', role: 'Flutter Developer', photoUrl: ''),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
      TeamModel(
        id: '2',
        name: 'Team B',
        projectName: 'Clothing app',
        description: 'Fashion app help you to refresh your style',
        supervisorId: supervisorId,
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(id: 'a3', name: 'Sara Ahmed', position: 'Teaching Assistant', photoUrl: ''),
        ],
        members: [
          TeamMember(id: 'm3', name: 'Aya Mosa', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm4', name: 'Dalia Gamal', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm6', name: 'Shahd Mohamed', role: 'Frontend Developer', photoUrl: ''),
          TeamMember(id: 'm2', name: 'Faten Hesham', role: 'Designer', photoUrl: ''),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
    ];
  }

  // دالة مساعدة لجلب فرق المعيد
  List<TeamModel> _getMockTeamsForAssistant(String assistantId) {
    // الفرق اللي المعيد مشارك فيها كمساعد
    return [
      TeamModel(
        id: '1',
        name: 'Team A',
        projectName: 'ProjHub Project',
        description: 'Building the next generation project management platform for modern teams',
        supervisorId: 'sup1',
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(id: assistantId, name: 'Alaa Nabil', position: 'Teaching Assistant', photoUrl: ''),
          TeamMember(id: 'a2', name: 'Mohamed Hassan', position: 'Lab Assistant', photoUrl: ''),
        ],
        members: [
          TeamMember(id: 'm1', name: 'Marwa Mohamed', role: 'Team Lead(Flutter)', photoUrl: ''),
          TeamMember(id: 'm2', name: 'Faten Hesham', role: 'Designer', photoUrl: ''),
          TeamMember(id: 'm3', name: 'Aya Mosa', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm4', name: 'Dalia Gamal', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm5', name: 'Asmaa Elsaid', role: 'Flutter Developer', photoUrl: ''),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
      TeamModel(
        id: '2',
        name: 'Team B',
        projectName: 'Clothing app',
        description: 'Fashion app help you to refresh your style',
        supervisorId: 'sup1',
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(id: 'a3', name: 'Sara Ahmed', position: 'Teaching Assistant', photoUrl: ''),
          TeamMember(id: assistantId, name: 'Alaa Nabil', position: 'Teaching Assistant', photoUrl: ''),
        ],
        members: [
          TeamMember(id: 'm3', name: 'Aya Mosa', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm4', name: 'Dalia Gamal', role: 'BackEnd Developer', photoUrl: ''),
          TeamMember(id: 'm6', name: 'Shahd Mohamed', role: 'Frontend Developer', photoUrl: ''),
          TeamMember(id: 'm2', name: 'Faten Hesham', role: 'Designer', photoUrl: ''),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
    ];
  }

  // دالة مساعدة لجلب فرق المستخدم العادي (لو احتجناها)
  List<TeamModel> _getMockTeamsForUser(String userId) {
    // المستخدم العادي (طالب) بيظهر في فريق واحد بس
    return [
      TeamModel(
        id: '1',
        name: 'Team A',
        projectName: 'ProjHub Project',
        description: 'Building the next generation project management platform',
        supervisorId: 'sup1',
        supervisorName: 'Dr. Mohamed',
        assistants: [
          TeamMember(id: 'a1', name: 'Alaa Nabil', position: 'Teaching Assistant', photoUrl: ''),
          TeamMember(id: 'a2', name: 'Mohamed Hassan', position: 'Lab Assistant', photoUrl: ''),
        ],
        members: [
          TeamMember(id: userId, name: 'Marwa Mohamed', role: 'Team Lead(Flutter)', photoUrl: ''),
          TeamMember(id: 'm2', name: 'Faten Hesham', role: 'Designer', photoUrl: ''),
          TeamMember(id: 'm3', name: 'Aya Mosa', role: 'BackEnd Developer', photoUrl: ''),
        ],
        createdAt: DateTime.now(),
        activeProjects: 1,
      ),
    ];
  }

  // إعادة تعيين القائمة (لو احتجناها)
  void clearTeams() {
    _teams.clear();
    emit(TeamsInitial());
  }
}