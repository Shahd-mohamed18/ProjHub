
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/models/project_model.dart';
import 'package:onboard/screens/projectScreens/add_project_screen.dart';
import 'package:onboard/widgets/project/project_card.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'E-Commerce',
    'Education',
    'Sport',
    'Tourism',
    'Disability',
    'Agriculture',
    'medical',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 222, 233, 247),
              Colors.white,
              Color(0xff7E9FCA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ProjectCubit, ProjectState>(
            builder: (context, state) {
              if (state.status == ProjectStatus.loading && state.projects.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Project> filteredProjects = state.getProjectsByCategory(selectedCategory);

              return Column(
                children: [
                  Container(
                    height: 100,
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Explore Projects',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.notification_add_outlined, size: 25),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddProjectScreen(),
                                  ),
                                );
                              },
                              child: const Icon(Icons.add_circle_outline, size: 25),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Categories
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selectedCategory == category
                                  ? Colors.blue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedCategory == category
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: selectedCategory == category
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Projects List
                  Expanded(
                    child: filteredProjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No projects yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first project',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredProjects.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProjectCard(project: filteredProjects[index]),
                              );
                            },
                          ),
                  ),
                  if (state.status == ProjectStatus.error)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        state.errorMessage ?? 'An error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}