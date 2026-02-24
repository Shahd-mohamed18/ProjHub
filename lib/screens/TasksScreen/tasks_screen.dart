// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:onboard/models/TaskModels/task_model.dart';
import 'package:onboard/models/TaskModels/completed_task_model.dart';
import 'package:onboard/models/TaskModels/team_task_model.dart';
import 'package:onboard/screens/TasksScreen/task_details_screen.dart';
import 'package:onboard/widgets/tasks/my_work/pending_task_card.dart';
import 'package:onboard/widgets/tasks/my_work/completed_task_card.dart';
import 'package:onboard/widgets/tasks/my_work/team_task_card.dart';
import 'package:onboard/screens/TasksScreen/submit_task_screen.dart'; 
import 'package:onboard/widgets/tasks/task_card.dart';
import 'package:onboard/screens/TasksScreen/team_screen.dart';
import 'package:onboard/widgets/tasks/meeting_card.dart'; 

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _currentIndex = 1; // My Work tab نشط افتراضياً
  List<TaskModel> _pendingTasks = [];
  List<CompletedTaskModel> _completedTasks = [];
  List<TeamTaskModel> _teamTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    _pendingTasks = TaskModel.mockTasks;
    _completedTasks = CompletedTaskModel.mockCompletedTasks;
    _teamTasks = TeamTaskModel.mockTeamTasks;
    
    setState(() => _isLoading = false);
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildAppBar(),
        _buildTabBar(),
        Expanded(
          child: _currentIndex == 0 ? _buildHomeTab() : _buildMyWorkTab(),
        ),
      ],
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
          const Text(
            'My Work',
            style: TextStyle(fontSize: 24, fontFamily: 'Roboto', color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      height: 51,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.27,
                      color: _currentIndex == 0 ? const Color(0xFF2196F3) : Colors.transparent,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Home',
                    style: TextStyle(
                      color: _currentIndex == 0 ? const Color(0xFF2196F3) : const Color(0xFF495565),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.27,
                      color: _currentIndex == 1 ? const Color(0xFF2196F3) : Colors.transparent,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'My Work',
                    style: TextStyle(
                      color: _currentIndex == 1 ? const Color(0xFF2196F3) : const Color(0xFF495565),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                    ),
                  ),
                ),
              ),
            ),
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
          padding: EdgeInsets.only(left: 32),
          child: Text(
            'New Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        ..._pendingTasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TaskCard(
            task: task,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
            ),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMyWorkTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Pending Section
        if (_pendingTasks.isNotEmpty) ...[
          Text(
            'Pending (${_pendingTasks.length})',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          ..._pendingTasks.map((task) => PendingTaskCard(
            task: task,
            onSubmit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailsScreen(task: task),
                ),
              );
            },
          )).toList(),
          const SizedBox(height: 16),
        ],

        // Completed Section
        if (_completedTasks.isNotEmpty) ...[
           Text(
            'Completed (${_completedTasks.length})',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 12),
          ..._completedTasks.map((task) => CompletedTaskCard(
            task: task,
          
          )).toList(),
          const SizedBox(height: 16),
        ],

        // Team Tasks Section
        if (_teamTasks.isNotEmpty) ...[
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TeamScreen()),
                  );
                  
                },
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
          ..._teamTasks.map((task) => TeamTaskCard(task: task)).toList(),
        ],
      ],
    );
  }
}