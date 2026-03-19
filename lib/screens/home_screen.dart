


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/screens/TasksScreen/tasks_screen.dart';
import 'package:onboard/screens/projectScreens/project_screen.dart';
import 'package:onboard/widgets/project/project_in_home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تحميل المشاريع عند فتح الصفحة الرئيسية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectCubit>().loadProjects();
    });

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
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: 40,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ProjHub',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 150),
                      Icon(Icons.search, size: 30),
                      Icon(Icons.notification_add_outlined, size: 30),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Chat Bot Button
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xff22C55E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset('assets/images/chatbot.png'),
                          ),
                          SizedBox(height: 5),
                          Text('Chat Bot'),
                        ],
                      ),
                      
                      // Tasks Button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TasksScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xD6FF002A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset('assets/images/task_icon.png'),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Tasks'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.only(left: 40, right: 40, bottom: 10),
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
                              Text(
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
                          SizedBox(height: 10),
                          Text('No tasks scheduled'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildFeaturedProjectsHeader(context),
                  _buildProjectsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProjectsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Featured Projects',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 22,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectScreen(),
                ),
              );
            },
            child: const Text(
              'See All',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
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

        // عرض أول 3 مشاريع فقط في الصفحة الرئيسية
        return Column(
          children: state.projects.take(3).map((project) {
            return ProjectInHomeWidget(project: project);
          }).toList(),
        );
      },
    );
  }
}