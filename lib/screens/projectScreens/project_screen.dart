
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onboard/cubits/project/project_cubit.dart';
// import 'package:onboard/models/project_model.dart';
// import 'package:onboard/screens/projectScreens/add_project_screen.dart';
// import 'package:onboard/widgets/project/project_card.dart';

// class ProjectScreen extends StatefulWidget {
//   const ProjectScreen({super.key});

//   @override
//   State<ProjectScreen> createState() => _ProjectScreenState();
// }

// class _ProjectScreenState extends State<ProjectScreen> {
//   String selectedCategory = 'All';
//   final List<String> categories = [
//     'All',
//     'E-Commerce',
//     'Education',
//     'Sport',
//     'Tourism',
//     'Disability',
//     'Agriculture',
//     'medical',
//   ];

//   @override
// void initState() {
//   super.initState();
//   context.read<ProjectCubit>().loadProjects(); // ✅ هتجيب من الباك اند مباشرة
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromARGB(255, 222, 233, 247),
//               Colors.white,
//               Color(0xff7E9FCA),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: BlocBuilder<ProjectCubit, ProjectState>(
//             builder: (context, state) {
//               if (state.status == ProjectStatus.loading && state.projects.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               List<Project> filteredProjects = state.getProjectsByCategory(selectedCategory);

//               return Column(
//                 children: [
//                   Container(
//                     height: 100,
//                     color: Colors.white,
//                     padding: const EdgeInsets.only(
//                       top: 20,
//                       left: 20,
//                       right: 20,
//                       bottom: 5,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Explore Projects',
//                           style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
//                         ),
//                         Row(
//                           children: [
//                             const Icon(Icons.notification_add_outlined, size: 25),
//                             const SizedBox(width: 15),
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const AddProjectScreen(),
//                                   ),
//                                 );
//                               },
//                               child: const Icon(Icons.add_circle_outline, size: 25),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Categories
//                   SizedBox(
//                     height: 40,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: categories.length,
//                       itemBuilder: (context, index) {
//                         String category = categories[index];
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedCategory = category;
//                             });
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 8),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               color: selectedCategory == category
//                                   ? Colors.blue
//                                   : Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: selectedCategory == category
//                                     ? Colors.transparent
//                                     : Colors.grey.shade300,
//                               ),
//                             ),
//                             child: Text(
//                               category,
//                               style: TextStyle(
//                                 color: selectedCategory == category
//                                     ? Colors.white
//                                     : Colors.grey.shade600,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // Projects List
//                   Expanded(
//                     child: filteredProjects.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.folder_open,
//                                   size: 80,
//                                   color: Colors.grey.shade400,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   'No projects yet',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Tap the + button to add your first project',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey.shade500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.all(16),
//                             itemCount: filteredProjects.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 12),
//                                 child: ProjectCard(project: filteredProjects[index]),
//                               );
//                             },
//                           ),
//                   ),
//                   if (state.status == ProjectStatus.error)
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         state.errorMessage ?? 'An error occurred',
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/models/project_model.dart';
import 'package:onboard/screens/projectScreens/add_project_screen.dart';
import 'package:onboard/screens/projectScreens/access_denied_screen.dart';
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
    'Medical', 
  ];

  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().loadProjects();
  }

  
  Future<void> _checkUserRoleAndNavigate() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
      
        _showAccessDeniedDialog(
          title: 'Login Required',
          message: 'Please login to upload projects',
          icon: Icons.login_rounded,
        );
        return;
      }
      
    
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      final userRole = userDoc.data()?['role'] ?? 'user';
      
      
      if (userRole == 'assistant' || userRole == 'supervisor') {
      
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccessDeniedScreen(userRole: userRole),
          ),
        );
      } else {
      
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddProjectScreen(),
          ),
        );
      }
    } catch (e) {
    
      _showAccessDeniedDialog(
        title: 'Error',
        message: 'Unable to verify your permissions. Please try again.',
        icon: Icons.error_outline,
      );
    }
  }
  

  void _showAccessDeniedDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff155DFC),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFDEE9F7),
              Colors.white,
              const Color(0xff7E9FCA),
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
                              onTap: _checkUserRoleAndNavigate, 
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