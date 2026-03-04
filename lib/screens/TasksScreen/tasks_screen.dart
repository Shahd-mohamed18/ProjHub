// lib/screens/TasksScreen/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/tasks/tasks_cubit.dart';
import 'package:onboard/cubits/tasks/tasks_state.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/feedback_model.dart';
import 'package:onboard/repositories/task_repository.dart';
import 'package:onboard/screens/TasksScreen/task_details_screen.dart';
import 'package:onboard/screens/TasksScreen/feedback_screen.dart';
import 'package:onboard/screens/TasksScreen/team_screen.dart';
import 'package:onboard/widgets/tasks/tasks_tab_bar.dart';
import 'package:onboard/widgets/tasks/meeting_card.dart';
import 'package:onboard/widgets/tasks/task_card.dart';
import 'package:onboard/widgets/tasks/my_work/pending_task_card.dart';
import 'package:onboard/widgets/tasks/my_work/completed_task_card.dart';
import 'package:onboard/repositories/mock_task_repository.dart';
import 'package:onboard/widgets/tasks/my_work/team_task_card.dart';

// ✅ TasksScreen ← تاني بتعمل setState
// كل الـ state بيتدار في TasksCubit
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _currentTabIndex = 0; 

  @override
  Widget build(BuildContext context) {
    // ✅ BlocProvider بنحطه هنا عشان الـ Cubit يعيش مع الشاشة دي بس
    return BlocProvider(
      create: (_) => TasksCubit(MockTaskRepository())..loadTasks(),
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
                onTabChanged: (index) =>
                    setState(() => _currentTabIndex = index),
              ),
              Expanded(
                child: BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, state) {
                    // ✅ Loading
                    if (state is TasksLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // ✅ Error مع زر Retry
                    if (state is TasksError) {
                      return _buildErrorView(
                        context,
                        message: state.message,
                        onRetry: () =>
                            context.read<TasksCubit>().refreshTasks(),
                      );
                    }

                    // ✅ Loaded
                    if (state is TasksLoaded) {
                      return _currentTabIndex == 0
                          ? _buildHomeTab(context, state)
                          : _buildMyWorkTab(context, state);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────
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
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
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
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Home Tab
  // ─────────────────────────────────────────────
  Widget _buildHomeTab(BuildContext context, TasksLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<TasksCubit>().refreshTasks(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // ✅ Meeting Card - البيانات دي هتيجي من الـ API قريباً
          const MeetingCard(
            doctorName: 'Dr Mohamed',
            date: '13 Feb',
            meetingLink: 'https://meet.google.com/fqs-rdab-duy',
            phoneNumber: '+1 404-793-6912',
            pin: '829 859 451#',
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              'New Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          if (state.pendingTasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No new tasks 🎉',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ...state.pendingTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TaskCard(
                  task: task,
                  onTap: () => _navigateToTaskDetails(context, task),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // My Work Tab
  // ─────────────────────────────────────────────
  Widget _buildMyWorkTab(BuildContext context, TasksLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<TasksCubit>().refreshTasks(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Pending Section
          if (state.pendingTasks.isNotEmpty) ...[
            Text(
              'Pending (${state.pendingTasks.length})',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),
            ...state.pendingTasks.map(
              (task) => PendingTaskCard(
                task: task,
                onSubmit: () => _navigateToTaskDetails(context, task),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Completed Section
          if (state.completedTasks.isNotEmpty) ...[
            Text(
              'Completed (${state.completedTasks.length})',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),
            ...state.completedTasks.map(
              (task) => CompletedTaskCard(
                task: task,
                // ✅ الـ Navigation بتحصل هنا في الـ Screen مش في الـ Widget
                onViewFeedback: () => _navigateToFeedback(context, task),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Team Tasks Section
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
                    color: Color(0xFF101828),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeamScreen()),
                  ),
                  child: const Text(
                    'View Team',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 18,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...state.teamTasks.map((task) => TeamTaskCard(task: task)),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Error View
  // ─────────────────────────────────────────────
  Widget _buildErrorView(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Navigation Helpers - كل الـ Navigation هنا
  // ─────────────────────────────────────────────
  void _navigateToTaskDetails(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
    );
  }

  void _navigateToFeedback(BuildContext context, CompletedTaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          taskId: task.id,
          taskTitle: task.title,
          // ✅ الـ feedbacks هتيجي من الـ API - مؤقتاً بنفلترها من الـ mock
          feedbacks: FeedbackModel.mockFeedbacks
              .where((f) => f.taskId == task.id)
              .toList(),
        ),
      ),
    );
  }
}