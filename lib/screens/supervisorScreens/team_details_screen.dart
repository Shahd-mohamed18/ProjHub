
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/chatScreens/chat_screen.dart';

class TeamDetailsScreen extends StatelessWidget {
  final TeamModel team;
  final UserRole userRole;

  const TeamDetailsScreen({
    super.key,
    required this.team,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final isSupervisor = userRole == UserRole.supervisor;
    final isAssistant = userRole == UserRole.assistant;
    final canAddTask = isSupervisor || isAssistant; // الدكتور أو المعيد يقدر يضيف Task

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
                          )
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
                                    team.name,
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 47.99,
                                                  height: 47.99,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFFDBEAFE),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(42600300),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      '👥',
                                                      style: TextStyle(
                                                        color: Color(0xFF0A0A0A),
                                                        fontSize: 24,
                                                        fontFamily: 'Arimo',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.33,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        team.projectName ?? 'No Project',
                                                        style: const TextStyle(
                                                          color: Color(0xFF101727),
                                                          fontSize: 16,
                                                          fontFamily: 'Arimo',
                                                          fontWeight: FontWeight.w400,
                                                          height: 1.50,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${team.totalMembers} Members',
                                                        style: const TextStyle(
                                                          color: Color(0xFF495565),
                                                          fontSize: 14,
                                                          fontFamily: 'Arimo',
                                                          fontWeight: FontWeight.w400,
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
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    team.description ?? 'No description',
                                                    style: const TextStyle(
                                                      color: Color(0xFF495565),
                                                      fontSize: 14,
                                                      fontFamily: 'Arimo',
                                                      fontWeight: FontWeight.w400,
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
                                                      fontWeight: FontWeight.w400,
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${team.activeProjects * 3}',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
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
                                      // Add Task - يظهر للدكتور والمعيد
                                      if (canAddTask)
                                        GestureDetector(
                                          onTap: () {
                                            // TODO: Add Task
                                            print('Add Task clicked by ${isSupervisor ? "Supervisor" : "Assistant"}');
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
                                      // Assistants Section (highlighted)
                                      if (team.assistants.isNotEmpty)
                                        ...team.assistants.map((assistant) => 
                                          _buildAssistantTile(context, assistant)
                                        ),

                                      // Members Section
                                      ...team.members.map((member) => 
                                        _buildMemberTile(context, member)
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Buttons - تظهر للدكتور فقط (لأنها إدارة)
                                if (isSupervisor)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                      // Add Members Button
                                      GestureDetector(
                                        onTap: () {
                                          // TODO: Add Members
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 48,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF155DFC),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
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

                                      // Remove Team Button
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
                                              borderRadius: BorderRadius.circular(10),
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

  // باقي الدوال كما هي بدون تغيير
  Widget _buildAssistantTile(BuildContext context, TeamMember assistant) {
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
                  assistant.position ?? 'Assistant',
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

  Widget _buildMemberTile(BuildContext context, TeamMember member) {
    return Container(
      
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.27,
            color: const Color(0xFFF2F4F6),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildMemberAvatar(member),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Color(0xFF101727),
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                Text(
                  member.role ?? 'Member',
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
                    otherUserId: member.id,
                    otherUserName: member.name,
                    otherUserPhoto: member.photoUrl,
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
                ? (isAssistant ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1))
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

  Widget _buildAvatarContent(TeamMember member, String? photoUrl, bool isAssistant) {
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
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(member, isAssistant),
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
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(member, isAssistant),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Team'),
          content: Text('Are you sure you want to remove "${team.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Remove team
                Navigator.pop(context);
                Navigator.pop(context);
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