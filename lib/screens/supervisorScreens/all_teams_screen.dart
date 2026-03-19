


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/teams/create_team_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/supervisorScreens/create_team_screen.dart';
import 'package:onboard/screens/supervisorScreens/team_details_screen.dart';
import 'package:onboard/widgets/team/team_card_widget.dart';

class AllTeamsScreen extends StatefulWidget {
  final UserRole userRole;

  const AllTeamsScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<AllTeamsScreen> createState() => _AllTeamsScreenState();
}

class _AllTeamsScreenState extends State<AllTeamsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    try {
      final authState = context.read<AuthCubit>().state;
      final userId = authState.userModel?.uid ?? '';
      if (userId.isNotEmpty) {
        context.read<TeamsCubit>().loadTeamsForUser(userId, widget.userRole);
      }
    } catch (e) {
      print('Error loading teams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSupervisor = widget.userRole == UserRole.supervisor;
    final isAssistant = widget.userRole == UserRole.assistant;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                width: double.infinity,
                height: 95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 48),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'All Teams',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header with Your Teams and New Team (للدكتور فقط)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: BlocBuilder<TeamsCubit, TeamsState>(
                  builder: (context, teamsState) {
                    int teamsCount = 0;
                    if (teamsState is TeamsLoaded) {
                      teamsCount = teamsState.teams.length;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Teams ($teamsCount)',
                          style: const TextStyle(
                            color: Color(0xFF101727),
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // New Team button - يظهر للدكتور فقط
                        if (isSupervisor)
                          GestureDetector(
                            onTap: () async {
                              print('📱 Opening Create Team Screen');

                              final newTeam = await Navigator.push<TeamModel?>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => CreateTeamCubit(),
                                    child: const CreateTeamScreen(),
                                  ),
                                ),
                              );

                              if (newTeam != null && mounted) {
                                print(
                                  '➕ Adding team returned from pop: ${newTeam.name}',
                                );
                                context.read<TeamsCubit>().addTeam(newTeam);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Team "${newTeam.name}" created successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              '+ New Team',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF155CFB),
                                fontSize: 18,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Teams List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 32, top: 8),
                  child: BlocBuilder<TeamsCubit, TeamsState>(
                    builder: (context, state) {
                      if (state is TeamsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is TeamsError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadTeams,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is TeamsLoaded) {
                        final teams = state.teams;

                        if (teams.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No teams yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isSupervisor
                                      ? 'Create your first team!'
                                      : 'You are not assigned to any team yet',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: teams.length,
                          itemBuilder: (context, index) {
                            final team = teams[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.99),
                              child: TeamCardWidget(
                                team: team,
                                userRole: widget.userRole,
                                onViewDetails: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeamDetailsScreen(
                                        team: team,
                                        userRole: widget.userRole,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
