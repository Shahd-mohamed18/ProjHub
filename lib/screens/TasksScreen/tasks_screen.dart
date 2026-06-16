// lib/screens/TasksScreen/tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/announcement/announcement_cubit.dart';
import 'package:onboard/cubits/announcement/announcement_state.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/tasks/tasks_cubit.dart';
import 'package:onboard/cubits/tasks/tasks_state.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/repositories/api_task_repository.dart';
import 'package:onboard/screens/TasksScreen/feedback_screen.dart';
import 'package:onboard/screens/TasksScreen/task_details_screen.dart';
import 'package:onboard/screens/TasksScreen/team_screen.dart';
import 'package:onboard/services/team_api_service.dart';
import 'package:onboard/widgets/tasks/announcement_card.dart';
import 'package:onboard/widgets/tasks/tasks_tab_bar.dart';
import 'package:onboard/widgets/tasks/task_card.dart';
import 'package:onboard/widgets/tasks/my_work/pending_task_card.dart';
import 'package:onboard/widgets/tasks/my_work/completed_task_card.dart';
import 'package:onboard/widgets/tasks/my_work/team_task_card.dart';
import 'package:onboard/screens/chatScreens/chat_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with WidgetsBindingObserver {
  late final TasksCubit _tasksCubit;
  late final AnnouncementCubit _announcementCubit;
  int _currentTabIndex = 0;
  bool _announcementLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tasksCubit = TasksCubit(ApiTaskRepository())..loadTasks();
    _announcementCubit = AnnouncementCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoadAnnouncements());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tasksCubit.close();
    _announcementCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) _tryLoadAnnouncements();
  }

  /// تحميل الإعلانات باستخدام userId الحالي (من AuthCubit)
  void _tryLoadAnnouncements() {
    if (!mounted) return;
    final teamsState = context.read<TeamsCubit>().state;
    if (teamsState is! TeamsLoaded || teamsState.teams.isEmpty) return;
    final teamId = int.tryParse(teamsState.teams.first.id);
    if (teamId == null) return;
    
    // ✅ الحصول على userId الحالي
    final userId = context.read<AuthCubit>().state.userModel?.uid;
    if (userId == null || userId.isEmpty) return; // تأكد من وجود userId
    
    _announcementLoaded = true;
    _announcementCubit.loadAnnouncements(
      teamId: teamId,
      userId: userId, // ✅ نمرر userId الصحيح
    );
  }

  // ── حذف الإعلان (للمشرف فقط) ──────────────────────────────────────────

  void _deleteAnnouncement(BuildContext context, int teamId, String supervisorId) {
    showDialog(
      context: context,
      builder: (dlg) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: const Text('سيتم حذف جميع الإعلانات لهذا الفريق. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dlg);
              _announcementCubit.deleteAnnouncements(
                teamId: teamId,
                supervisorId: supervisorId,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _tasksCubit),
        BlocProvider.value(value: _announcementCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEFF6FF),
                Color(0xFFF4F4F4),
                Color(0xFF7D9FCA),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              TasksTabBar(
                currentIndex: _currentTabIndex,
                onTabChanged: (i) => setState(() => _currentTabIndex = i),
              ),
              Expanded(
                child: _currentTabIndex == 0
                    ? _buildHomeTab(context)
                    : _buildMyWorkTab(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.only(top: 48, left: 24, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Work',
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    color: Colors.black),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showTeamDetails(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF155CFB).withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 18, color: Color(0xFF155CFB)),
                    SizedBox(width: 4),
                    Text(
                      'My Team',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF155CFB),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamDetails(BuildContext context) {
    final teamsState = context.read<TeamsCubit>().state;
    if (teamsState is! TeamsLoaded || teamsState.teams.isEmpty) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TeamScreen()));
      return;
    }
    final team = teamsState.teams.first;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamDetailsSheet(team: team),
    );
  }

  // ── Home Tab ────────────────────────────────────────────────────────────────

  Widget _buildHomeTab(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.userModel;
    final isSupervisor = user?.role == UserRole.supervisor;
    final supervisorId = user?.uid ?? '';
    int? currentTeamId;

    final teamsState = context.read<TeamsCubit>().state;
    if (teamsState is TeamsLoaded && teamsState.teams.isNotEmpty) {
      currentTeamId = int.tryParse(teamsState.teams.first.id);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _tasksCubit.refreshTasks();
        _tryLoadAnnouncements();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // ── PINNED: Announcements ──────────────────────────────────
          BlocConsumer<TeamsCubit, TeamsState>(
            listenWhen: (p, c) => c is TeamsLoaded,
            listener: (ctx, teamsState) {
              if (!_announcementLoaded) _tryLoadAnnouncements();
            },
            builder: (ctx, _) {
              return BlocConsumer<AnnouncementCubit, AnnouncementState>(
                listener: (ctx, annoState) {
                  if (annoState is AnnouncementDeleted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف الإعلان بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (annoState is AnnouncementError) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(annoState.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (ctx, annoState) {
                  if (annoState is AnnouncementLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    );
                  }
                  if (annoState is AnnouncementLoaded &&
                      annoState.announcements.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...annoState.announcements.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AnnouncementCard(
                              supervisorName: a.supervisorName,
                              date: a.formattedDate,
                              message: a.message,
                              meetingLink: a.meetingLink,
                              onDelete: (isSupervisor && currentTeamId != null)
                                  ? () => _deleteAnnouncement(ctx, currentTeamId!, supervisorId)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),

          const SizedBox(height: 8),

          // ── Tasks section ──────────────────────────────────────────
          BlocBuilder<TasksCubit, TasksState>(
            builder: (ctx, state) {
              if (state is TasksLoading) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ));
              }
              if (state is TasksError) {
                return _buildErrorView(ctx,
                    message: state.message,
                    onRetry: () => _tasksCubit.refreshTasks());
              }
              if (state is TasksLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 32),
                      child: Text(
                        'New Tasks',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.pendingTasks.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No new tasks 🎉',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ...state.pendingTasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TaskCard(
                            task: task,
                            onTap: () =>
                                _navigateToTaskDetails(ctx, task),
                          ),
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // ── My Work Tab ─────────────────────────────────────────────────────────────

  Widget _buildMyWorkTab(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (ctx, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TasksError) {
          return _buildErrorView(ctx,
              message: state.message,
              onRetry: () => _tasksCubit.refreshTasks());
        }
        if (state is TasksLoaded) {
          return RefreshIndicator(
            onRefresh: () => _tasksCubit.refreshTasks(),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                if (state.pendingTasks.isNotEmpty) ...[
                  Text(
                    'Pending (${state.pendingTasks.length})',
                    style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 12),
                  ...state.pendingTasks.map(
                    (task) => PendingTaskCard(
                      task: task,
                      onSubmit: () => _navigateToTaskDetails(ctx, task),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (state.completedTasks.isNotEmpty) ...[
                  Text(
                    'Completed (${state.completedTasks.length})',
                    style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 12),
                  ...state.completedTasks.map(
                    (task) => CompletedTaskCard(
                      task: task,
                      onTap: task.taskModel != null
                          ? () =>
                              _navigateToTaskDetails(ctx, task.taskModel!)
                          : null,
                      onViewFeedback: () =>
                          _navigateToFeedback(ctx, task),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (state.teamTasks.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Team Tasks',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) => const TeamScreen()),
                        ),
                        child: const Text(
                          'View Team',
                          style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontSize: 18,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...state.teamTasks
                      .map((task) => TeamTaskCard(task: task)),
                ],
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorView(BuildContext context,
      {required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3)),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _navigateToTaskDetails(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _tasksCubit,
          child: TaskDetailsScreen(task: task, tasksCubit: _tasksCubit),
        ),
      ),
    ).then((_) => _tryLoadAnnouncements());
  }

  void _navigateToFeedback(BuildContext context, CompletedTaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FeedbackScreen(taskId: task.id, taskTitle: task.title),
      ),
    );
  }
}

// ── Team Details Bottom Sheet ────────────────────────────────────────────────

class _TeamDetailsSheet extends StatefulWidget {
  final TeamModel team;
  const _TeamDetailsSheet({required this.team});

  @override
  State<_TeamDetailsSheet> createState() => _TeamDetailsSheetState();
}

class _TeamDetailsSheetState extends State<_TeamDetailsSheet> {
  TeamModel? _fullTeam;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details =
          await TeamApiService().getTeamDetails(widget.team.id);
      if (mounted) {
        setState(() {
          _fullTeam = details ?? widget.team;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fullTeam = widget.team;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = _fullTeam ?? widget.team;
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(team.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700)),
            if (team.projectName?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(team.projectName!,
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF495565))),
            ],
            if (team.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(team.description!,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF697282))),
            ],
            const SizedBox(height: 20),
            _supervisorRow(
                team.supervisorId, team.supervisorName ?? 'Not assigned'),
            const Divider(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (team.assistants.isNotEmpty) ...[
                const Text('Assistants',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...team.assistants.map((a) => _memberTile(
                    id: a.id,
                    name: a.name,
                    role: a.position ?? a.role ?? 'Assistant',
                    color: Colors.purple)),
                const SizedBox(height: 16),
              ],
              if (team.members.isNotEmpty) ...[
                const Text('Team Members',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...team.members
                    .where((m) =>
                        m.id != team.supervisorId &&
                        (m.position == null || m.position!.isEmpty))
                    .map((m) => _memberTile(
                        id: m.id,
                        name: m.name,
                        role: m.role ?? 'Member',
                        color: Colors.blue)),
              ],
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155DFC),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Close',
                    style:
                        TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supervisorRow(String supervisorId, String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.school_outlined,
              size: 18, color: Color(0xFF155CFB)),
          const SizedBox(width: 8),
          const Text('Supervisor: ',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF495565))),
          ),
          if (supervisorId.isNotEmpty)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: supervisorId,
                    otherUserName: name,
                  ),
                ),
              ),
              child: const Text(
                'Message',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF155CFB),
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _memberTile({
    required String id,
    required String name,
    required String role,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(role,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF697282))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  otherUserId: id,
                  otherUserName: name,
                ),
              ),
            ),
            child: const Text(
              'Message',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF155CFB),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}