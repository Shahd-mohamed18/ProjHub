// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/task_model.dart';
import 'package:onboard/screens/task_details_screen.dart'; // ✅ إضافة
import 'package:onboard/widgets/tasks/meeting_card.dart';
import 'package:onboard/widgets/tasks/task_card.dart';
import 'package:onboard/widgets/tasks/tasks_tab_bar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _currentTabIndex = 0;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      _tasks = TaskModel.mockTasks;
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });

    try {
      // TODO: Update in backend
      print('Task ${task.id} updated');
    } catch (e) {
      setState(() {
        task.isCompleted = !task.isCompleted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            _buildAppBar(context),
            TasksTabBar(
              currentIndex: _currentTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _currentTabIndex == 0
                          ? _buildHomeTab()
                          : _buildMyWorkTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.only(top: 48, left: 24, bottom: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/main');
              }
            },
            child: Container(
              width: 32,
              height: 32,
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Something went wrong'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTasks,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        const MeetingCard(
          doctorName: 'Dr Mohamed',
          date: '13 Feb',
          meetingLink: 'https://meet.google.com/fqs-rdab-duy',
          phoneNumber: '+1 404-793-6912',
          pin: '829 859 451#',
        ),

        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.only(left: 32, bottom: 16),
          child: Text(
            'New Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
        ),

        if (_tasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ..._tasks.map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TaskCard(
              task: task,
              onTap: () { // ✅ هنا التنقل لصفحة التفاصيل
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailsScreen(task: task),
                  ),
                );
              },
              onIconTap: () => _toggleTaskCompletion(task),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildMyWorkTab() {
    final completedTasks = _tasks.where((task) => task.isCompleted).toList();
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        if (completedTasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No completed tasks yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ...completedTasks.map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TaskCard(
              task: task,
              onTap: () { // ✅ هنا برضو للـ completed tasks
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailsScreen(task: task),
                  ),
                );
              },
              onIconTap: () => _toggleTaskCompletion(task),
            ),
          )).toList(),
      ],
    );
  }
}