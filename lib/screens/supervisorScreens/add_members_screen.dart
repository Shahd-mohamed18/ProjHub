import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TeamModels/team_member.dart';
import 'package:onboard/models/TeamModels/team_model.dart';

class AddMembersScreen extends StatefulWidget {
  final TeamModel team;

  const AddMembersScreen({super.key, required this.team});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  List<TeamMember> _allUsers = [];
  List<TeamMember> _selectedMembers = [];
  bool _isLoading = true;
  bool _isAdding = false;
  String _searchQuery = '';

  Set<String> _studentsInOtherTeams = {};

  @override
  void initState() {
    super.initState();
    _loadUsersAndCheckTeams();
  }

  Future<void> _loadUsersAndCheckTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .get();
      final studentsInAllTeams = <String>{};

      for (var doc in teamsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final teamId = data['id']?.toString() ?? doc.id;
        if (teamId == widget.team.id) continue;

        final members = data['members'] as List? ?? [];
        for (var member in members) {
          if (member is Map && member['id'] != null) {
            studentsInAllTeams.add(member['id']);
          }
        }
      }

      _studentsInOtherTeams = studentsInAllTeams;

      final allUsers = await context
          .read<TeamsCubit>()
          .getStudentsFromFirebase();

      final existingMemberIds = widget.team.members.map((m) => m.id).toSet();
      final existingAssistantIds = widget.team.assistants
          .map((a) => a.id)
          .toSet();
      final allExistingIds = {...existingMemberIds, ...existingAssistantIds};

      setState(() {
        _allUsers = allUsers
            .where((u) => !allExistingIds.contains(u.id))
            .toList();
        _isLoading = false;
      });

      print('✅ Available users to add: ${_allUsers.length}');
      print(
        '   Students already in other teams: ${_studentsInOtherTeams.length}',
      );
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isUserInOtherTeam(TeamMember user) {
    return _studentsInOtherTeams.contains(user.id);
  }

  void _toggleSelection(TeamMember user) {
    if (_isUserInOtherTeam(user)) {
      _showSnackBar('${user.name} is already in another team!', isError: true);
      return;
    }

    setState(() {
      final index = _selectedMembers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _selectedMembers.removeAt(index);
      } else {
        _selectedMembers.add(user);
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _addMembers() async {
    if (_selectedMembers.isEmpty) {
      _showSnackBar('Please select at least one member', isError: true);
      return;
    }

    final invalidMembers = _selectedMembers
        .where((m) => _isUserInOtherTeam(m))
        .toList();
    if (invalidMembers.isNotEmpty) {
      final invalidNames = invalidMembers.map((m) => m.name).join(', ');
      _showSnackBar(
        'Cannot add: $invalidNames (already in another team)',
        isError: true,
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    final success = await context.read<TeamsCubit>().addMembersToTeam(
      teamId: widget.team.id,
      newMembers: _selectedMembers,
    );

    setState(() {
      _isAdding = false;
    });

    if (success && mounted) {
      _showSnackBar('Added ${_selectedMembers.length} members successfully');
      await _loadUsersAndCheckTeams();
      setState(() {
        _selectedMembers.clear();
      });
      Navigator.pop(context, true);
    } else if (mounted) {
      await _loadUsersAndCheckTeams();
      setState(() {
        _selectedMembers.clear();
      });
      // ✅ إرجاع false عند الفشل
      Navigator.pop(context, false);
    }
  }

  List<TeamMember> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    return _allUsers
        .where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamsCubit, TeamsState>(
      listener: (context, state) {
        if (state is TeamMembersAddWarning) {
          _showSnackBar(state.warning, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16,
                        top: 48,
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
                              'Add Members',
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
                      if (_selectedMembers.isNotEmpty)
                        Positioned(
                          right: 16,
                          top: 48,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF155CFB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_selectedMembers.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search members...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),

                // Users List
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No members available to add'
                                      : 'No members found',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final isSelected = _selectedMembers.any(
                                (u) => u.id == user.id,
                              );
                              final isInOtherTeam = _isUserInOtherTeam(user);

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFEFF6FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF155CFB)
                                        : (isInOtherTeam
                                              ? Colors.red.shade300
                                              : const Color(0xFFF2F4F6)),
                                    width: isInOtherTeam ? 1.5 : 1,
                                  ),
                                ),
                                child: Opacity(
                                  opacity: isInOtherTeam ? 0.6 : 1.0,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isInOtherTeam
                                          ? Colors.red.shade100
                                          : (isSelected
                                                ? const Color(0xFF155CFB)
                                                : Colors.grey.shade300),
                                      radius: 20,
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: isInOtherTeam
                                              ? Colors.red.shade700
                                              : (isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade700),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: isInOtherTeam
                                                  ? Colors.red.shade700
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        if (isInOtherTeam)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.red.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 12,
                                                  color: Colors.red.shade700,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'In Team',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.red.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      isInOtherTeam
                                          ? 'Already enrolled in another team'
                                          : (user.role ??
                                                user.position ??
                                                'Member'),
                                      style: TextStyle(
                                        color: isInOtherTeam
                                            ? Colors.red.shade700
                                            : Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF155CFB),
                                            size: 24,
                                          )
                                        : (isInOtherTeam
                                              ? const Icon(
                                                  Icons.block,
                                                  color: Colors.red,
                                                  size: 24,
                                                )
                                              : const Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.grey,
                                                  size: 24,
                                                )),
                                    onTap: isInOtherTeam
                                        ? null
                                        : () => _toggleSelection(user),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // Add Button
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isAdding ? null : _addMembers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF155DFC),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Add ${_selectedMembers.isEmpty ? '' : '(${_selectedMembers.length})'} Members',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
