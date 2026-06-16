
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/notification/notification_cubit.dart';
import 'package:onboard/services/notification2_service.dart';
import 'package:onboard/screens/AIScreen/ai_welcome_screen.dart';
import 'package:onboard/screens/TasksScreen/tasks_screen.dart';
import 'package:onboard/screens/projectScreens/project_screen.dart';
import 'package:onboard/screens/notifications_screen.dart';
import 'package:onboard/screens/search_screen.dart';
import 'package:onboard/widgets/project/project_in_home_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
    // تحميل المشاريع عند فتح الصفحة الرئيسية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectCubit>().loadProjects();
    });
  }

  Future<void> _initNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final authState = context.read<AuthCubit>().state;
    final userId = authState.userModel?.uid;
    
    if (userId != null && userId.isNotEmpty) {
      try {
        await Notification2Service.instance.init(userId);
        await context.read<NotificationCubit>().loadNotifications(userId);
        
        Notification2Service.instance.onNotification.listen((notification) {
          if (mounted) {
            context.read<NotificationCubit>().addNewNotification(notification);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(notification.message),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      } catch (e) {
        print('⚠️ Error initializing notifications: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userId = authState.userModel?.uid ?? '';
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 222, 233, 247),
              Color(0xffF4F4F4),
              Color(0xff7E9FCA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(userId),
            _buildQuickActions(),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userId) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(
        top: 40,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ProjHub',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              
              // زر البحث - يفتح شاشة جديدة
              IconButton(
                icon: const Icon(Icons.search, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              
              // زر الإشعارات مع العلامة
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  if (state is NotificationsLoaded) {
                    unreadCount = state.unreadCount;
                  }
                  
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          ).then((_) {
                            if (userId.isNotEmpty) {
                              context.read<NotificationCubit>().loadNotifications(userId);
                            }
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Image.asset('assets/images/chatbot.png', width: 30, height: 30),
            label: 'AI Assistant',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIWelcomeScreen(),
                ),
              );
            },
            color: const Color(0xff22C55E),
          ),
          
          _buildActionButton(
            icon: Image.asset('assets/images/task_icon.png', width: 30, height: 30),
            label: 'Tasks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TasksScreen(),
                ),
              );
            },
            color: const Color(0xD6FF002A),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: icon,
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }

  Widget _buildMainContent() {
    return ListView(
      children: [
        _buildThisWeekCard(),
        const SizedBox(height: 15),
        _buildFeaturedProjectsHeader(),
        _buildProjectsList(),
      ],
    );
  }

  Widget _buildThisWeekCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 30,
          left: 20,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'View to-do list',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('No tasks scheduled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProjectsHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Featured Projects',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectScreen()),
              );
            },
            child: const Text(
              'See All',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        if (state.status == ProjectStatus.loading && state.projects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.projects.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.folder_open, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: state.projects.take(3).map((project) {
            return ProjectInHomeWidget(project: project);
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}