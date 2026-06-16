import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/repositories/api_task_repository.dart';
import 'package:onboard/screens/supervisorScreens/all_members_screen.dart';
import 'package:onboard/screens/supervisorScreens/all_tasks_screen.dart';
import 'package:onboard/screens/supervisorScreens/all_teams_screen.dart';
import 'package:onboard/screens/supervisorScreens/supervisor_projects_screen.dart';
import 'package:onboard/screens/supervisorScreens/team_details_screen.dart';

import 'dart:io';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  int _taskCount = 0;
  bool _loadingTasks = false;

  @override
  void initState() {
    super.initState();
    _loadTaskCount();
  }

  Future<void> _loadTaskCount() async {
    final authState = context.read<AuthCubit>().state;
    final userId = authState.userModel?.uid ?? '';
    if (userId.isEmpty) return;

    setState(() => _loadingTasks = true);
    try {
      final tasks = await ApiTaskRepository().getTasksBySupervisor(userId);
      setState(() {
        _taskCount = tasks.length;
        _loadingTasks = false;
      });
    } catch (e) {
      setState(() => _loadingTasks = false);
    }
  }

  String _getGreeting(UserRole role, String name) {
    switch (role) {
      case UserRole.supervisor:
        return 'Hello Dr.$name';
      case UserRole.assistant:
        return 'Hello Eng.$name';
      default:
        return 'Hello $name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final teamsState = context.watch<TeamsCubit>().state;
    final user = authState.userModel;
    final userRole = user?.role ?? UserRole.user;
    final isSupervisor = userRole == UserRole.supervisor;

    final userName = user?.fullName.split(' ').first ?? 'Mohamed';
    final userPhoto = user?.photoUrl;
    final userId = user?.uid ?? '';

    if (teamsState is TeamsInitial && userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TeamsCubit>().loadTeamsForUser(userId, userRole);
      });
    }

    int teamsCount = 0;
    int membersCount = 0;
    int projectsCount = 0;
    List<TeamModel> teams = [];
    List<TeamModel> recentTeams = [];

    if (teamsState is TeamsLoaded) {
      teams = teamsState.teams;
      teamsCount = teams.length;
      projectsCount = teams.length;
      final Set<String> memberIds = {};
      for (var team in teams) {
        for (var m in team.members) memberIds.add(m.id);
        for (var a in team.assistants) memberIds.add(a.id);
      }
      membersCount = memberIds.length;
      recentTeams = teams.take(3).toList();
    }

    return Container(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 20, left: 24, right: 24, bottom: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: _buildProfileImage(userPhoto, userName),
                          ),
                        ),
                        const SizedBox(width: 22),
                        Text(
                          _getGreeting(userRole, userName),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    const Icon(Icons.notification_add_outlined,
                        size: 28, color: Colors.black),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats Cards ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  AllTeamsScreen(userRole: userRole)),
                        ),
                        child:
                            _buildStatCard('Teams', teamsCount.toString()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SupervisorProjectsScreen()),
                        ),
                        child: _buildStatCard(
                            'Projects', projectsCount.toString()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isSupervisor) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AllMembersScreen(teams: teams)),
                          ),
                          child: _buildStatCard(
                              'Members', membersCount.toString()),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // ✅ Tasks stat card – shows real task count
                    Expanded(
                      child: _buildTasksCard(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Your Teams ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Teams ($teamsCount)',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AllTeamsScreen(userRole: userRole)),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF155CFB),
                              fontSize: 14,
                              fontFamily: 'Arimo',
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (teamsState is TeamsLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (recentTeams.isEmpty)
                      _buildEmptyTeams(isSupervisor)
                    else
                      ...recentTeams.map(
                        (team) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeamDetailsScreen(
                                  team: team,
                                  userRole: userRole,
                                ),
                              ),
                            ),
                            child: _buildTeamCard(
                              teamName: team.name,
                              projectName:
                                  team.projectName ?? 'No Project',
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tasks stat card — navigates to AllTasksScreen ──────────────
  Widget _buildTasksCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllTasksScreen()),
      ),
      child: _buildStatCard(
        'Tasks',
        _loadingTasks ? '...' : _taskCount.toString(),
      ),
    );
  }

  Widget _buildEmptyTeams(bool isSupervisor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No teams yet',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            isSupervisor
                ? 'Create your first team!'
                : 'You are not assigned to any team yet',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? photoUrl, String userName) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return Image.network(photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialsImage(userName));
      } else {
        return Image.file(File(photoUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialsImage(userName));
      }
    }
    return _buildInitialsImage(userName);
  }

  Widget _buildInitialsImage(String userName) {
    return Container(
      color: Colors.blue.shade100,
      child: Center(
        child: Text(
          userName[0].toUpperCase(),
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A)),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: double.infinity,
      height: 78,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          color: Color(0x40000000))
                    ])),
            Text(value,
                style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 22,
                    fontFamily: 'Sansita Swashed',
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(
      {required String teamName, required String projectName}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: Color(0xFFF2F4F6)),
          borderRadius: BorderRadius.circular(14),
        ),
        shadows: const [
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1),
          BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          const Text('👥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teamName,
                    style: const TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 18,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text(projectName,
                    style: const TextStyle(
                        color: Color(0xFF495565),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}