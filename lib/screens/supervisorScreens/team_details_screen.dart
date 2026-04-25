
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/chatScreens/chat_screen.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/screens/supervisorScreens/add_members_screen.dart';
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
    // ✅ دائماً نجلب أحدث البيانات عند فتح الصفحة
    _fetchTeamDetails();
  }

  // ✅ دالة جديدة لجلب البيانات دائماً
  Future<void> _fetchTeamDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teamApiService = TeamApiService();
      final teamDetails = await teamApiService.getTeamDetails(_team.id);

      if (teamDetails != null && mounted) {
        print('✅ Team details fetched successfully!');
        print('   Assistants: ${teamDetails.assistants.length}');
        print('   Members: ${teamDetails.members.length}');

        setState(() {
          _team = teamDetails;
          _isLoading = false;
        });
      } else {
        print('⚠️ No team details received from backend');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('⚠️ Error fetching team details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ دالة لتحديث البيانات بعد إضافة أعضاء
  Future<void> _refreshTeamDetails() async {
    await _fetchTeamDetails();
  }

  @override
  Widget build(BuildContext context) {
    final isSupervisor = widget.userRole == UserRole.supervisor;
    final isAssistant = widget.userRole == UserRole.assistant;
    final canAddTask = isSupervisor || isAssistant;

    return BlocListener<TeamsCubit, TeamsState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is TeamsLoaded) {
          final teamStillExists = state.teams.any(
            (team) => team.id == _team.id,
          );

          if (!teamStillExists && mounted) {
            print('✅ Team deleted, navigating back');
            Navigator.pop(context);
          }
        }
      },
      child: _buildScaffold(isSupervisor, isAssistant, canAddTask),
    );
  }

  Widget _buildScaffold(bool isSupervisor, bool isAssistant, bool canAddTask) {
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
              child: Container(
                width: 393,
                height: 914,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 48,
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
                      child: Stack(
                        children: [
                          Positioned(
                            left: 16,
                            top: 48,
                            child: Container(
                              width: 270,
                              height: 24,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16,
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

                    // Main Content
                    Container(
                      width: 341,
                      height: 667,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 22,
                          children: [
                            // Project Info Card
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 33,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 32,
                                  children: [
                                    // Project Details Card
                                    Container(
                                      width: double.infinity,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1.27,
                                            color: Color(0xFFF2F4F6),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: -1,
                                          ),
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 47.99,
                                                  height: 47.99,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFFDBEAFE,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            42600300,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      '👥',
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF0A0A0A,
                                                        ),
                                                        fontSize: 24,
                                                        fontFamily: 'Arimo',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.33,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _team.projectName ??
                                                            'No Project',
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF101727,
                                                          ),
                                                          fontSize: 16,
                                                          fontFamily: 'Arimo',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.50,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${_team.totalMembers} Members',
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF495565,
                                                          ),
                                                          fontSize: 14,
                                                          fontFamily: 'Arimo',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.43,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _team.description ??
                                                        'No description',
                                                    style: const TextStyle(
                                                      color: Color(0xFF495565),
                                                      fontSize: 14,
                                                      fontFamily: 'Arimo',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.43,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                const SizedBox(
                                                  width: 82,
                                                  child: Text(
                                                    'Add \nNotes',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xFF155CFB),
                                                      fontSize: 18,
                                                      fontFamily: 'Arimo',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Total Tasks Card
                                    Container(
                                      width: double.infinity,
                                      height: 78,
                                      padding: const EdgeInsets.only(
                                        top: 13.25,
                                        left: 13.25,
                                        right: 13.25,
                                        bottom: 1.27,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1.27,
                                            color: Color(0xFFF2F4F6),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: -1,
                                          ),
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${_team.activeProjects * 3}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFF155CFB),
                                              fontSize: 24,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.33,
                                            ),
                                          ),
                                          const Text(
                                            'Total Tasks',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF495565),
                                              fontSize: 12,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.33,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Team Members Section
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 24,
                              children: [
                                // Header
                                Container(
                                  width: double.infinity,
                                  height: 24,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          onTap: () {
                                            print('Add Task clicked');
                                          },
                                          child: const Text(
                                            '+ Add Task',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF155CFB),
                                              fontSize: 18,
                                              fontFamily: 'Arimo',
                                              fontWeight: FontWeight.w400,
                                              height: 1.11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Members List Container
                                Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  width: double.infinity,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1.27,
                                        color: Color(0xFFF2F4F6),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x19000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                        spreadRadius: -1,
                                      ),
                                      BoxShadow(
                                        color: Color(0x19000000),
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // ✅ Assistants Section (المعيدين)
                                      if (_team.assistants.isNotEmpty)
                                        ..._team.assistants.map(
                                          (assistant) => _buildAssistantTile(
                                            context,
                                            assistant,
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'No assistants assigned yet',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                      // ✅ Students Section (الطلاب)
                                      if (_getStudentsOnly().isNotEmpty)
                                        ..._getStudentsOnly().map(
                                          (student) => _buildStudentTile(
                                            context,
                                            student,
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            'No students assigned yet',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Action Buttons
                                if (isSupervisor)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AddMembersScreen(team: _team),
                                            ),
                                          );

                                          if (result == true && mounted) {
                                            // ✅ تحديث البيانات بعد إضافة الأعضاء
                                            await _refreshTeamDetails();

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Team members updated successfully',
                                                ),
                                                backgroundColor: Colors.green,
                                                behavior:
                                                    SnackBarBehavior.floating,
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Add Members',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Arimo',
                                                fontWeight: FontWeight.w400,
                                                height: 1.50,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: () {
                                          _showDeleteDialog(context);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 50.51,
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                width: 1.27,
                                                color: Color(0xFFFFA1A2),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Remove Team',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFFE7000A),
                                                fontSize: 16,
                                                fontFamily: 'Arimo',
                                                fontWeight: FontWeight.w400,
                                                height: 1.50,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                              ],
                            ),
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

  // ✅ دالة لجلب الطلاب فقط (استبعاد المعيدين)
  // List<TeamMember> _getStudentsOnly() {
  //   return _team.members.where((member) {
  //     // استبعاد المعيدين (اللي عندهم position)
  //     if (member.position != null && member.position!.isNotEmpty) return false;
  //     return true;
  //   }).toList();
  // }
  // ✅ دالة لجلب الطلاب فقط (استبعاد المعيدين والمشرف)
  List<TeamMember> _getStudentsOnly() {
    return _team.members.where((member) {
      // استبعاد المشرف (الدكتور)
      if (member.id == _team.supervisorId) return false;
      // استبعاد المعيدين (اللي عندهم position)
      if (member.position != null && member.position!.isNotEmpty) return false;
      return true;
    }).toList();
  }

  Widget _buildAssistantTile(BuildContext context, TeamMember assistant) {
    String subtitle = assistant.position ?? 'Assistant';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFFEF9C2),
        border: Border(
          bottom: BorderSide(width: 1.27, color: Color(0xFFF2F4F6)),
        ),
      ),
      child: Row(
        children: [
          _buildMemberAvatar(assistant, isAssistant: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assistant.name,
                  style: const TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: assistant.id,
                    otherUserName: assistant.name,
                    otherUserPhoto: assistant.photoUrl,
                  ),
                ),
              );
            },
            child: const Text(
              'Message',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF155CFB),
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ دالة عرض الطلاب مع الـ Track الخاص بهم
  Widget _buildStudentTile(BuildContext context, TeamMember student) {
    String track = student.role ?? 'Student';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.27, color: const Color(0xFFF2F4F6)),
        ),
      ),
      child: Row(
        children: [
          _buildMemberAvatar(student),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                Text(
                  track,
                  style: const TextStyle(
                    color: Color(0xFF697282),
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: student.id,
                    otherUserName: student.name,
                    otherUserPhoto: student.photoUrl,
                  ),
                ),
              );
            },
            child: const Text(
              'Message',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF155CFB),
                fontSize: 14,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(TeamMember member, {bool isAssistant = false}) {
    final photoUrl = member.photoUrl;

    return Stack(
      children: [
        Container(
          width: 39.99,
          height: 39.99,
          decoration: ShapeDecoration(
            color: photoUrl == null || photoUrl.isEmpty
                ? (isAssistant
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1))
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(42600300),
            ),
          ),
          child: _buildAvatarContent(member, photoUrl, isAssistant),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 11.98,
            height: 11.98,
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

  Widget _buildAvatarContent(
    TeamMember member,
    String? photoUrl,
    bool isAssistant,
  ) {
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(42600300),
        child: Image.network(
          photoUrl,
          width: 39.99,
          height: 39.99,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildFallbackAvatar(member, isAssistant),
        ),
      );
    }

    if (photoUrl.startsWith('assets')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(42600300),
        child: Image.asset(
          photoUrl,
          width: 39.99,
          height: 39.99,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildFallbackAvatar(member, isAssistant),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(42600300),
      child: Image.file(
        File(photoUrl),
        width: 39.99,
        height: 39.99,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackAvatar(member, isAssistant),
      ),
    );
  }

  Widget _buildFallbackAvatar(TeamMember member, bool isAssistant) {
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Team'),
          content: Text('Are you sure you want to remove "${_team.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final snackBar = ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Removing team...'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: Duration(days: 1),
                  ),
                );

                final success = await context.read<TeamsCubit>().deleteTeam(
                  _team.id,
                );

                if (mounted) {
                  snackBar.close();
                }

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Team removed successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove team'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
