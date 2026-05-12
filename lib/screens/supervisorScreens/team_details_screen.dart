import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/repositories/mock_task_repository.dart';
import 'package:onboard/screens/chatScreens/chat_screen.dart';
import 'package:onboard/screens/supervisorScreens/add_members_screen.dart';
import 'package:onboard/screens/supervisorScreens/create_task_screen.dart';
import 'package:onboard/services/team_api_service.dart';

class TeamDetailsScreen extends StatefulWidget {
  final TeamModel team;
  final UserRole userRole;

  const TeamDetailsScreen({
    super.key,
    required this.team,
    required this.userRole,
  });

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  late TeamModel _team;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    _fetchTeamDetails();
  }

  Future<void> _fetchTeamDetails() async {
    setState(() => _isLoading = true);
    try {
      final teamApiService = TeamApiService();
      final teamDetails = await teamApiService.getTeamDetails(_team.id);
      if (teamDetails != null && mounted) {
        setState(() {
          _team = teamDetails;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('⚠️ Error fetching team details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshTeamDetails() => _fetchTeamDetails();

  void _navigateToCreateTask(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final supervisorId = authState.userModel?.uid ?? '';
    final teamsCubit = context.read<TeamsCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SupervisorTaskCubit(
            MockTaskRepository(),
            teamsCubit,
          ),
          child: CreateTaskScreen(
            supervisorId: supervisorId,
            teamId: _team.id,
            teamMembers: _team.members,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSupervisor = widget.userRole == UserRole.supervisor;
    final isAssistant = widget.userRole == UserRole.assistant;
    final canAddTask = isSupervisor || isAssistant;

    return BlocListener<TeamsCubit, TeamsState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is TeamsLoaded) {
          final stillExists = state.teams.any((t) => t.id == _team.id);
          if (!stillExists && mounted) Navigator.pop(context);
        }
      },
      child: _buildScaffold(isSupervisor, isAssistant, canAddTask),
    );
  }

  Widget _buildScaffold(
    bool isSupervisor,
    bool isAssistant,
    bool canAddTask,
  ) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, -0.00),
              end: Alignment(0.50, 1.00),
              colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: 393,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: 393,
                height: 914,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 95,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 16,
                            top: 48,
                            child: SizedBox(
                              width: 270,
                              height: 24,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _team.name,
                                    style: const TextStyle(
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildProjectCard(),
                            const SizedBox(height: 16),
                            _buildTotalTasksCard(),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Team Members',
                                  style: TextStyle(
                                    color: Color(0xFF101727),
                                    fontSize: 16,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                if (canAddTask)
                                  GestureDetector(
                                    onTap: () => _navigateToCreateTask(context),
                                    child: const Text(
                                      '+ Add Task',
                                      style: TextStyle(
                                        color: Color(0xFF155CFB),
                                        fontSize: 18,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildMembersList(),
                            const SizedBox(height: 22),
                            if (isSupervisor) ...[
                              _buildAddMembersButton(),
                              const SizedBox(height: 12),
                              _buildRemoveTeamButton(),
                              const SizedBox(height: 30),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard() {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFDBEAFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(42600300),
                    ),
                  ),
                  child: const Center(
                    child: Text('👥',
                        style: TextStyle(fontSize: 24, fontFamily: 'Arimo')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _team.projectName ?? 'No Project',
                        style: const TextStyle(
                            color: Color(0xFF101727),
                            fontSize: 16,
                            fontFamily: 'Arimo'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_team.totalMembers} Members',
                        style: const TextStyle(
                            color: Color(0xFF495565),
                            fontSize: 14,
                            fontFamily: 'Arimo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _team.description ?? 'No description',
                    style: const TextStyle(
                        color: Color(0xFF495565),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        height: 1.43),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Add \nNotes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF155CFB),
                      fontSize: 18,
                      fontFamily: 'Arimo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTasksCard() {
    return Container(
      width: double.infinity,
      height: 78,
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
              color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${_team.activeProjects * 3}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF155CFB),
                fontSize: 24,
                fontFamily: 'Arimo'),
          ),
          const Text(
            'Total Tasks',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF495565),
                fontSize: 12,
                fontFamily: 'Arimo'),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    List<TeamMember> assistants = _team.assistants;
    List<TeamMember> students = _getStudentsOnly();

    return Container(
      width: double.infinity,
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
              color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          // Assistants Section
          if (assistants.isNotEmpty)
            ...assistants.map((a) => _buildAssistantTile(context, a))
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No assistants assigned yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ),
          // Students Section
          if (students.isNotEmpty)
            ...students.map((s) => _buildStudentTile(context, s))
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No students assigned yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  List<TeamMember> _getStudentsOnly() {
    return _team.members.where((member) {
      if (member.id == _team.supervisorId) return false;
      if (member.position != null && member.position!.isNotEmpty) return false;
      return true;
    }).toList();
  }

  Widget _buildAssistantTile(BuildContext context, TeamMember assistant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF9C2),
        border: Border(
            bottom: BorderSide(width: 1.27, color: Color(0xFFF2F4F6))),
      ),
      child: Row(
        children: [
          _buildAvatar(assistant, isAssistant: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assistant.name,
                    style: const TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 14,
                        fontFamily: 'Arimo')),
                Text(assistant.position ?? 'Assistant',
                    style: const TextStyle(
                        color: Color(0xFF697282),
                        fontSize: 12,
                        fontFamily: 'Arimo')),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  otherUserId: assistant.id,
                  otherUserName: assistant.name,
                  otherUserPhoto: assistant.photoUrl,
                ),
              ),
            ),
            child: const Text('Message',
                style: TextStyle(
                    color: Color(0xFF155CFB),
                    fontSize: 14,
                    fontFamily: 'Arimo')),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, TeamMember student) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(width: 1.27, color: Color(0xFFF2F4F6))),
      ),
      child: Row(
        children: [
          _buildAvatar(student),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: const TextStyle(
                        color: Color(0xFF101727),
                        fontSize: 14,
                        fontFamily: 'Arimo')),
                Text(student.role ?? 'Student',
                    style: const TextStyle(
                        color: Color(0xFF697282),
                        fontSize: 12,
                        fontFamily: 'Arimo')),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  otherUserId: student.id,
                  otherUserName: student.name,
                  otherUserPhoto: student.photoUrl,
                ),
              ),
            ),
            child: const Text('Message',
                style: TextStyle(
                    color: Color(0xFF155CFB),
                    fontSize: 14,
                    fontFamily: 'Arimo')),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TeamMember member, {bool isAssistant = false}) {
    final photoUrl = member.photoUrl;
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: photoUrl == null || photoUrl.isEmpty
                ? (isAssistant
                    ? Colors.purple.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1))
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: _avatarContent(member, photoUrl, isAssistant),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: ShapeDecoration(
              color: const Color(0xFF00C950),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.27, color: Colors.white),
                borderRadius: BorderRadius.circular(42600300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarContent(
      TeamMember member, String? photoUrl, bool isAssistant) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return Center(
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: isAssistant ? Colors.purple : Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (photoUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(photoUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _fallbackAvatar(member, isAssistant)),
      );
    }
    if (photoUrl.startsWith('assets')) {
      return ClipOval(
        child: Image.asset(photoUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _fallbackAvatar(member, isAssistant)),
      );
    }
    return ClipOval(
      child: Image.file(File(photoUrl),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _fallbackAvatar(member, isAssistant)),
    );
  }

  Widget _fallbackAvatar(TeamMember member, bool isAssistant) {
    return Center(
      child: Text(
        member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: isAssistant ? Colors.purple : Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddMembersButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddMembersScreen(team: _team),
          ),
        );
        if (result == true && mounted) {
          await _refreshTeamDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Team members updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: ShapeDecoration(
          color: const Color(0xFF155DFC),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: const Center(
          child: Text('Add Members',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Arimo')),
        ),
      ),
    );
  }

  Widget _buildRemoveTeamButton() {
    return GestureDetector(
      onTap: () => _showDeleteDialog(context),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1.27, color: Color(0xFFFFA1A2)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Center(
          child: Text('Remove Team',
              style: TextStyle(
                  color: Color(0xFFE7000A),
                  fontSize: 16,
                  fontFamily: 'Arimo')),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Remove Team'),
        content: Text('Are you sure you want to remove "${_team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final snack =
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Row(children: [
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 12),
                  Text('Removing team…'),
                ]),
                backgroundColor: Colors.blue,
                duration: Duration(days: 1),
              ));
              final success =
                  await context.read<TeamsCubit>().deleteTeam(_team.id);
              if (mounted) snack.close();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Team removed successfully'
                      : 'Failed to remove team'),
                  backgroundColor: success ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}