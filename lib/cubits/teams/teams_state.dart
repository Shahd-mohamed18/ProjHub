// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onboard/models/TeamModels/team_model.dart';
// import 'package:onboard/models/TeamModels/team_member.dart';

// // States
// abstract class TeamsState {}

// class TeamsInitial extends TeamsState {}

// class TeamsLoading extends TeamsState {}

// class TeamsLoaded extends TeamsState {
//   final List<TeamModel> teams;
//   TeamsLoaded({required this.teams});
// }

// class TeamsError extends TeamsState {
//   final String message;
//   TeamsError({required this.message});
// }

// class TeamMembersAddWarning extends TeamsState {
//   final String warning;
//    TeamMembersAddWarning({required this.warning});
  
//   @override
//   List<Object> get props => [warning];
// }
// lib/cubits/teams/teams_state.dart
import 'package:equatable/equatable.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';

abstract class TeamsState extends Equatable {
  const TeamsState();
  
  @override
  List<Object?> get props => [];
}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<TeamModel> teams;
  
  const TeamsLoaded({required this.teams});
  
  @override
  List<Object> get props => [teams];
}

class TeamsError extends TeamsState {
  final String message;
  
  const TeamsError({required this.message});
  
  @override
  List<Object> get props => [message];
}

class TeamMembersAddWarning extends TeamsState {
  final String warning;
  
  TeamMembersAddWarning({required this.warning});
  
  @override
  List<Object> get props => [warning];
}