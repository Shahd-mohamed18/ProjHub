import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';

// States
abstract class TeamsState {}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<TeamModel> teams;
  TeamsLoaded({required this.teams});
}

class TeamsError extends TeamsState {
  final String message;
  TeamsError({required this.message});
}
