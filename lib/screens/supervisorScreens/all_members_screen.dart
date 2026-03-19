// lib/screens/supervisorScreens/all_members_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/TeamModels/team_member.dart';

class AllMembersScreen extends StatelessWidget {
  final List<TeamModel> teams;

  const AllMembersScreen({super.key, required this.teams});

  @override
  Widget build(BuildContext context) {
    // Collect all unique members
    final Map<String, MemberWithTeam> membersMap = {};

    for (var team in teams) {
      // Add assistants
      for (var assistant in team.assistants) {
        if (!membersMap.containsKey(assistant.id)) {
          membersMap[assistant.id] = MemberWithTeam(
            member: assistant,
            teams: [team.name],
            role: 'Assistant',
          );
        } else {
          membersMap[assistant.id]!.teams.add(team.name);
        }
      }

      // Add members
      for (var member in team.members) {
        if (!membersMap.containsKey(member.id)) {
          membersMap[member.id] = MemberWithTeam(
            member: member,
            teams: [team.name],
            role: member.role ?? 'Member',
          );
        } else {
          membersMap[member.id]!.teams.add(team.name);
        }
      }
    }

    final members = membersMap.values.toList();

    // Separate assistants and members
    final assistants = members.where((m) => m.role == 'Assistant').toList();
    final students = members.where((m) => m.role != 'Assistant').toList();

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
                        'All Members',
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

              // Stats - تم إصلاح مشكلة overflow
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatChip(
                        'Total',
                        members.length.toString(),
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'Assistants',
                        assistants.length.toString(),
                        Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'Students',
                        students.length.toString(),
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              // Members List
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF1E3A8A),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          tabs: const [
                            Tab(text: 'Assistants'),
                            Tab(text: 'Students'),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          children: [
                            // Assistants Tab
                            _buildMembersList(assistants, isAssistant: true),
                            // Students Tab
                            _buildMembersList(students),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(
    List<MemberWithTeam> members, {
    bool isAssistant = false,
  }) {
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAssistant ? Icons.school_outlined : Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isAssistant ? 'assistants' : 'students'} yet',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final memberWithTeam = members[index];
        final member = memberWithTeam.member;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAssistant
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isAssistant ? Colors.purple : Colors.blue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Member Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101727),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.displayRole,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF495565),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Teams
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: memberWithTeam.teams.map((teamName) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            teamName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF155CFB),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Message button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(
                    color: Color(0xFF155CFB),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MemberWithTeam {
  final TeamMember member;
  final List<String> teams;
  final String role;

  MemberWithTeam({
    required this.member,
    required this.teams,
    required this.role,
  });
}