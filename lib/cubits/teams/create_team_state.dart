


// lib/cubits/teams/create_team_state.dart
import 'package:onboard/models/TeamModels/team_member.dart';

abstract class CreateTeamState {}

class CreateTeamInitial extends CreateTeamState {}

class CreateTeamLoading extends CreateTeamState {}

class UsersLoading extends CreateTeamState {} // حالة تحميل المستخدمين

class UsersSearchLoading extends CreateTeamState {}

class UsersSearchLoaded extends CreateTeamState {
  final List<TeamMember> assistants;
  final List<TeamMember> members;
  UsersSearchLoaded({required this.assistants, required this.members});
}

class UsersLoaded extends CreateTeamState { // حالة بعد تحميل كل المستخدمين
  final List<TeamMember> allAssistants;
  final List<TeamMember> allMembers;
  UsersLoaded({required this.allAssistants, required this.allMembers});
}

class AssistantToggled extends CreateTeamState {
  final List<TeamMember> selectedAssistants;
  final List<TeamMember> selectedMembers;
  AssistantToggled({required this.selectedAssistants, required this.selectedMembers});
}

class MemberToggled extends CreateTeamState {
  final List<TeamMember> selectedAssistants;
  final List<TeamMember> selectedMembers;
  MemberToggled({required this.selectedAssistants, required this.selectedMembers});
}

class TeamCreated extends CreateTeamState {
  final String teamId;
  TeamCreated({required this.teamId});
}

class CreateTeamError extends CreateTeamState {
  final String message;
  CreateTeamError({required this.message});
}