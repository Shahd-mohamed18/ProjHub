
import 'package:equatable/equatable.dart';
import 'package:onboard/models/TeamModels/team_member.dart';

abstract class CreateTeamState extends Equatable {
  const CreateTeamState();
  
  @override
  List<Object?> get props => [];
}

class CreateTeamInitial extends CreateTeamState {}

class CreateTeamLoading extends CreateTeamState {}

class TeamCreated extends CreateTeamState {
  final String teamId;
  const TeamCreated({required this.teamId});
  
  @override
  List<Object> get props => [teamId];
}

class CreateTeamError extends CreateTeamState {
  final String message;
  const CreateTeamError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class CreateTeamWarning extends CreateTeamState {
  final String message;
  const CreateTeamWarning({required this.message});
  
  @override
  List<Object> get props => [message];
}

class UsersLoading extends CreateTeamState {}

class UsersSearchLoading extends CreateTeamState {}

class UsersSearchLoaded extends CreateTeamState {
  final List<TeamMember> assistants;
  final List<TeamMember> members;
  final Set<String> studentsAlreadyInTeams;
  
  const UsersSearchLoaded({
    required this.assistants,
    required this.members,
    this.studentsAlreadyInTeams = const {},
  });
  
  @override
  List<Object?> get props => [assistants, members, studentsAlreadyInTeams];
}

class AssistantToggled extends CreateTeamState {
  final List<TeamMember> selectedAssistants;
  final List<TeamMember> selectedMembers;
  const AssistantToggled({required this.selectedAssistants, required this.selectedMembers});
  
  @override
  List<Object> get props => [selectedAssistants, selectedMembers];
}

class MemberToggled extends CreateTeamState {
  final List<TeamMember> selectedAssistants;
  final List<TeamMember> selectedMembers;
  const MemberToggled({required this.selectedAssistants, required this.selectedMembers});
  
  @override
  List<Object> get props => [selectedAssistants, selectedMembers];
}