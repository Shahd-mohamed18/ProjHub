
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/teams/create_team_cubit.dart';
import 'package:onboard/cubits/teams/create_team_state.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _teamNameController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  String _currentSearchQuery = '';
  bool _showAssistants = true;
  
  // نحتفظ بالـ cubit كـ variable عشان نستخدمه في dispose
  late CreateTeamCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<CreateTeamCubit>();
    _cubit.loadUsersFromFirebase();
    
    _searchController.addListener(() {
      setState(() {
        _currentSearchQuery = _searchController.text;
      });
      _cubit.searchUsers(_currentSearchQuery);
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    // استخدام _cubit بدل context.read
    _cubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTeamCubit, CreateTeamState>(
      listener: (context, state) {
        if (state is TeamCreated) {
          // الفريق اتعمل بنجاح - هنستخدم createdTeam من الكيوبت
          if (_cubit.createdTeam != null && mounted) {
            Navigator.pop(context, _cubit.createdTeam);
          }
        } else if (state is CreateTeamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Create New Team',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
              ),
            ),
            child: state is CreateTeamLoading
                ? const Center(child: CircularProgressIndicator())
                : state is UsersLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Team Name'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _teamNameController,
                              hint: 'Enter team name',
                            ),
                            const SizedBox(height: 20),

                            _buildLabel('Project Name'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _projectNameController,
                              hint: 'Enter project name',
                            ),
                            const SizedBox(height: 20),

                            _buildLabel('Description'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _descriptionController,
                              hint: "Describe the team's purpose and goals",
                              maxLines: 3,
                            ),
                            const SizedBox(height: 30),

                            _buildSearchSection(),
                            const SizedBox(height: 20),
                            _buildToggleTabs(),
                            const SizedBox(height: 16),
                            _buildResultsList(state),
                            const SizedBox(height: 30),
                            _buildSelectedCounts(),
                            const SizedBox(height: 30),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Search Users'),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAssistants = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showAssistants ? const Color(0xFF1E3A8A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Assistants',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showAssistants ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAssistants = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showAssistants ? const Color(0xFF1E3A8A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Members',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !_showAssistants ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(CreateTeamState state) {
    if (state is UsersSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UsersSearchLoaded) {
      final items = _showAssistants ? state.assistants : state.members;
      
      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              _searchController.text.isEmpty
                  ? 'No ${_showAssistants ? 'assistants' : 'members'} found'
                  : 'No users matching "${_searchController.text}"',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return CheckboxListTile(
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(item.displayRole),
              value: item.isSelected,
              onChanged: (_) {
                if (_showAssistants) {
                  _cubit.toggleAssistant(item);
                } else {
                  _cubit.toggleMember(item);
                }
              },
              activeColor: const Color(0xFF1E3A8A),
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildSelectedCounts() {
    return BlocBuilder<CreateTeamCubit, CreateTeamState>(
      builder: (context, state) {
        final assistantsCount = _cubit.getSelectedAssistantsCount();
        final membersCount = _cubit.getSelectedMembersCount();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSelectedChip('Assistants', assistantsCount, Colors.purple),
              Container(width: 1, height: 30, color: Colors.grey.shade300),
              _buildSelectedChip('Members', membersCount, Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedChip(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final supervisorId = authState.userModel?.uid ?? '';
        final supervisorName = authState.userModel?.fullName ?? 'Dr.';

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_teamNameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter team name'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                      ),
                    );
                    return;
                  }
                  
                  _cubit.createTeam(
                    teamName: _teamNameController.text.trim(),
                    projectName: _projectNameController.text.trim(),
                    description: _descriptionController.text.trim(),
                    supervisorId: supervisorId,
                    supervisorName: supervisorName,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Team',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}