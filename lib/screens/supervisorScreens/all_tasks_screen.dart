// lib/screens/supervisor/all_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/screens/TasksScreen/task_details_screen.dart';
import 'package:onboard/screens/supervisorScreens/give_feedback_screen.dart'; // ✅ إضافة الـ import الناقص

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authCubit = context.read<AuthCubit>();
    final supervisorId = authCubit.state.userModel?.uid ?? 'supervisor_1';
    // ✅ مش بنبعت teams - SupervisorTaskCubit بياخدها من TeamsCubit مباشرة
    context.read<SupervisorTaskCubit>().loadSupervisorData(supervisorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Color(0xFFF4F4F4), Color(0xFF7D9FCA)],
          ),
        ),
        child: BlocBuilder<SupervisorTaskCubit, SupervisorTaskState>(
          builder: (context, state) {
            if (state is SupervisorTaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SupervisorTaskError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            if (state is SupervisorTasksLoaded) {
              return Column(
                children: [
                  _buildAppBar(),
                  _buildTeamFilter(state.teams, state.selectedTeamId),
                  Expanded(
                    child: state.allTasks.isEmpty
                        ? const Center(
                            child: Text('No tasks yet',
                                style: TextStyle(color: Colors.grey, fontSize: 16)))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                _buildInProgressSection(context, state),
                                const SizedBox(height: 24),
                                _buildCompletedSection(context, state),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.only(top: 48, left: 24, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('All Tasks', style: TextStyle(fontSize: 24, fontFamily: 'Roboto')),
        ],
      ),
    );
  }

  Widget _buildTeamFilter(List<TeamModel> teams, String? selectedTeamId) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All (${teams.length})',
              isSelected: selectedTeamId == null,
              onTap: () => context.read<SupervisorTaskCubit>().filterByTeam(null),
            ),
            const SizedBox(width: 8),
            ...teams.map((team) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: team.name,
                isSelected: selectedTeamId == team.id,
                onTap: () => context.read<SupervisorTaskCubit>().filterByTeam(team.id),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF155DFC) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF354152),
              fontSize: 14, fontFamily: 'Arimo',
            )),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF155DFC).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$title ($count)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Color(0xFF101828), fontFamily: 'Arimo')),
        ],
      ),
    );
  }

  Widget _buildInProgressSection(BuildContext context, SupervisorTasksLoaded state) {
    final tasks = state.inProgressTasks;
    if (tasks.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('In Progress', tasks.length),
        ...tasks.map((task) => _buildInProgressCard(context, task, state)),
      ],
    );
  }

  Widget _buildInProgressCard(BuildContext context, TaskModel task, SupervisorTasksLoaded state) {
    final teamList = state.teams.where((t) => t.id == task.teamId);
    final teamName = teamList.isNotEmpty ? teamList.first.name : task.teamId;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(task.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF101828)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                  child: Text(teamName,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF155DFC), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(task.from, style: const TextStyle(fontSize: 12, color: Color(0xFF4A5565))),
            const SizedBox(height: 8),
            Text('Due: ${task.formattedDueDate}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A5565))),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedSection(BuildContext context, SupervisorTasksLoaded state) {
    final tasks = state.completedTasks;
    if (tasks.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Completed This Week', tasks.length),
        ...tasks.map((task) => _buildCompletedCard(context, task, state)),
      ],
    );
  }

  Widget _buildCompletedCard(BuildContext context, TaskModel task, SupervisorTasksLoaded state) {
    final teamList = state.teams.where((t) => t.id == task.teamId);
    final teamName = teamList.isNotEmpty ? teamList.first.name : task.teamId;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20, height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 12),
                ),
                Expanded(child: Text(task.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF101828)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                  child: Text(teamName,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF155DFC), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(task.from, style: const TextStyle(fontSize: 12, color: Color(0xFF4A5565))),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, fontFamily: 'Arimo'),
                        children: [
                          const TextSpan(text: 'Completed: ', style: TextStyle(color: Color(0xFF4A5565))),
                          TextSpan(text: '${task.formattedDueDate} • Approved',
                              style: const TextStyle(color: Color(0xFF00A63D))),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => GiveFeedbackScreen(task: task))),
                    child: const Text('Feedback',
                        style: TextStyle(fontSize: 12, color: Color(0xFF155CFB), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}