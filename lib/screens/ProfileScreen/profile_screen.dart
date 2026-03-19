
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onboard/cubits/auth/auth_cubit.dart';
// import 'package:onboard/cubits/project/project_cubit.dart';
// import 'package:onboard/models/project_model.dart';
// import 'package:onboard/models/user_model.dart';
// import 'package:onboard/screens/ProfileScreen/edit_profile_screen.dart';
// import 'package:onboard/screens/ProfileScreen/settings_screen.dart';
// import 'package:onboard/screens/community/community_screen.dart';
// import 'package:onboard/screens/projectScreens/project_details_screen.dart';
// import 'package:onboard/screens/projectScreens/project_screen.dart';
// import 'package:onboard/screens/projectScreens/edit_project_screen.dart';
// import 'package:onboard/screens/projectScreens/delete_confirmation_dialog.dart';
// import 'dart:io';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   bool _showAllProjects = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProjects();
//   }

//   Future<void> _loadUserProjects() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       context.read<ProjectCubit>().loadUserProjects(user.uid);
//     }
//   }

//   void _handleEditProject(Project project) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProjectScreen(project: project),
//       ),
//     );

//     if (result == true && mounted) {
//       _loadUserProjects();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Project updated successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   void _handleDeleteProject(String projectId, String projectTitle) {
//     showDialog(
//       context: context,
//       builder: (context) => DeleteConfirmationDialog(
//         projectTitle: projectTitle,
//         onConfirm: () async {
//           await context.read<ProjectCubit>().deleteProject(projectId);
//           if (mounted) {
//             _loadUserProjects();
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Project deleted successfully!'),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, authState) {
//         if (authState.status == AuthStatus.loading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (authState.userModel == null) {
//           return Scaffold(
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Failed to load profile data'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<AuthCubit>().logout();
//                       Navigator.pushReplacementNamed(context, '/login');
//                     },
//                     child: const Text('Go to Login'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         final userModel = authState.userModel!;

//         return Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFFEFF6FF),
//                   Color(0xFFF4F4F4),
//                   Color(0xFF7D9FCA),
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.only(bottom: 40),
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     _buildAppBar(context),
//                     const SizedBox(height: 24),
//                     _buildProfileHeader(userModel),
//                     const SizedBox(height: 32),
//                     _buildActionButtons(context, userModel),
//                     const SizedBox(height: 48),
//                     _buildProjectsSection(userModel),
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAppBar(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 4,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.arrow_back_ios_new, size: 24),
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Profile',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsScreen()),
//               );
//             },
//             child: Container(
//               width: 32,
//               height: 32,
//               child: const Icon(Icons.settings, size: 24),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileHeader(UserModel userModel) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: const BoxDecoration(color: Colors.transparent),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 128,
//             height: 128,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
//             ),
//             child: ClipOval(child: _buildProfileImage(userModel)),
//           ),
//           const SizedBox(width: 24),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   userModel.fullName,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   _getUserInfo(userModel),
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.black,
//                     height: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getUserInfo(UserModel userModel) {
//     switch (userModel.role) {
//       case UserRole.user:
//         return '${userModel.bio ?? 'User'}\n${userModel.university ?? 'University not set'}';
//       case UserRole.assistant:
//         return '${userModel.position ?? 'Assistant'}\n${userModel.department ?? 'Department not set'}';
//       case UserRole.supervisor:
//         return '${userModel.position ?? 'Supervisor'}\n${userModel.department ?? 'Department not set'}';
//     }
//   }

//   Widget _buildProfileImage(UserModel userModel) {
//     const placeholder = Icon(Icons.person, size: 50, color: Color(0xFF1E3A8A));
//     const placeholderBg = Color(0xFFDBEAFE);

//     Widget withBg(Widget child) =>
//         Container(color: placeholderBg, child: child);

//     final url = userModel.photoUrl;

//     if (url == null || url.isEmpty) return withBg(placeholder);

//     if (url.startsWith('http')) {
//       return Image.network(
//         url,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => withBg(placeholder),
//       );
//     }

//     if (url.startsWith('assets')) {
//       return Image.asset(
//         url,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => withBg(placeholder),
//       );
//     }

//     return Image.file(
//       File(url),
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => withBg(placeholder),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, UserModel userModel) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildActionButton(
//             label: 'Edit',
//             bgColor: const Color(0xFFDBEAFE),
//             assetPath: 'assets/images/Frame 176.png',
//             fallbackIcon: Icons.edit,
//             iconPadding: const EdgeInsets.all(8),
//             onTap: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => EditProfileScreen(
//                     currentName: userModel.fullName,
//                     currentBio: userModel.bio ?? '',
//                     currentUniversity: userModel.university,
//                     currentPosition: userModel.position,
//                     currentDepartment: userModel.department,
//                     currentImage: userModel.photoUrl ?? '',
//                     role: userModel.role,
//                   ),
//                 ),
//               );

//               if (result == true && mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Profile updated successfully!'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               }
//             },
//           ),
//           _buildActionButton(
//             label: 'Tasks',
//             bgColor: const Color(0xDBFF002A),
//             assetPath: 'assets/images/task_icon.png',
//             fallbackIcon: Icons.task,
//             iconPadding: const EdgeInsets.all(8),
//             onTap: () {
//               print('Tasks tapped');
//             },
//           ),
//           _buildActionButton(
//             label: 'chat bot',
//             bgColor: const Color(0xFFA8FF97),
//             assetPath: 'assets/images/chatbot_icon.png',
//             fallbackIcon: Icons.smart_toy,
//             iconPadding: const EdgeInsets.all(12),
//             onTap: () {
//               print('Chat Bot tapped');
//             },
//           ),
//           _buildActionButton(
//             label: 'Posts',
//             bgColor: const Color(0x99C69AFE),
//             assetPath: 'assets/images/Frame 183.png',
//             fallbackIcon: Icons.post_add,
//             iconPadding: const EdgeInsets.symmetric(horizontal: 8),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CommunityScreen(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required String label,
//     required Color bgColor,
//     required String assetPath,
//     required IconData fallbackIcon,
//     required EdgeInsets iconPadding,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 72,
//         height: 96,
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
//         decoration: ShapeDecoration(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           shadows: const [
//             BoxShadow(
//               color: Color(0x3F000000),
//               blurRadius: 4,
//               offset: Offset(0, 4),
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 56,
//               height: 56,
//               padding: iconPadding,
//               decoration: ShapeDecoration(
//                 color: bgColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(28),
//                 ),
//               ),
//               child: Image.asset(
//                 assetPath,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) =>
//                     Icon(fallbackIcon, color: Colors.black87, size: 24),
//               ),
//             ),
//             const SizedBox(height: 4),
//             SizedBox(
//               width: 60,
//               child: Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w300,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectsSection(UserModel userModel) {
//     return BlocBuilder<ProjectCubit, ProjectState>(
//       builder: (context, state) {
//         final userProjects = state.getProjectsByUser(userModel.uid);
//         final displayProjects = _showAllProjects
//             ? userProjects
//             : userProjects.take(2).toList();

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'My Projects',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       if (userProjects.length > 2)
//                         TextButton(
//                           onPressed: () {
//                             setState(() {
//                               _showAllProjects = !_showAllProjects;
//                             });
//                           },
//                           child: Text(
//                             _showAllProjects ? 'show less' : 'see all',
//                             style: const TextStyle(
//                               color: Color(0xFF3B82F6),
//                               fontSize: 18,
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                         ),
//                       const SizedBox(width: 8),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const ProjectScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Explore All Projects →',
//                           style: TextStyle(
//                             color: Color(0xFF3B82F6),
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               if (state.status == ProjectStatus.loading)
//                 const Center(child: CircularProgressIndicator())
//               else if (userProjects.isEmpty)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Column(
//                     children: [
//                       Icon(Icons.folder_open, size: 60, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         'No projects yet',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 ...displayProjects.map(
//                   (project) => _buildProjectCard(project, userModel),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProjectCard(Project project, UserModel userModel) {
//     final isOwner = project.authorId == userModel.uid;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ProjectDetailsScreen(project: project),
//                 ),
//               );
//             },
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 91,
//                   height: 97,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: const Color(0xFFDBEAFE),
//                   ),
//                   child: project.images.isNotEmpty
//                       ? (project.images.first.startsWith('http')
//                             ? Image.network(
//                                 project.images.first,
//                                 fit: BoxFit.cover,
//                               )
//                             : Image.file(
//                                 File(project.images.first),
//                                 fit: BoxFit.cover,
//                               ))
//                       : const Icon(
//                           Icons.business_center,
//                           size: 40,
//                           color: Color(0xFF1E3A8A),
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         project.title,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         project.description,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black54,
//                           fontWeight: FontWeight.w500,
//                           height: 1.4,
//                         ),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isOwner) ...[
//             const Divider(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton.icon(
//                   onPressed: () => _handleEditProject(project),
//                   icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
//                   label: const Text(
//                     'Edit',
//                     style: TextStyle(color: Colors.blue, fontSize: 16),
//                   ),
//                 ),
//                 Container(
//                   height: 20,
//                   width: 1,
//                   color: Colors.grey.shade300,
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                 ),
//                 TextButton.icon(
//                   onPressed: () =>
//                       _handleDeleteProject(project.id, project.title),
//                   icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//                   label: const Text(
//                     'Delete',
//                     style: TextStyle(color: Colors.red, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/teams/teams_state.dart';
import 'package:onboard/models/project_model.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/models/TeamModels/team_model.dart';
import 'package:onboard/screens/ProfileScreen/edit_profile_screen.dart';
import 'package:onboard/screens/ProfileScreen/settings_screen.dart';
import 'package:onboard/screens/community/community_screen.dart';
import 'package:onboard/screens/projectScreens/project_details_screen.dart';
import 'package:onboard/screens/projectScreens/project_screen.dart';
import 'package:onboard/screens/projectScreens/edit_project_screen.dart';
import 'package:onboard/screens/projectScreens/delete_confirmation_dialog.dart';
import 'package:onboard/screens/supervisorScreens/team_details_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showAllProjects = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final authState = context.read<AuthCubit>().state;
    final userModel = authState.userModel;
    
    if (user != null) {
      context.read<ProjectCubit>().loadUserProjects(user.uid);
    }
    
    if (userModel != null) {
      context.read<TeamsCubit>().loadTeamsForUser(userModel.uid, userModel.role);
    }
  }

  String _getProjectsSectionTitle(UserRole role) {
    switch (role) {
      case UserRole.supervisor:
        return 'My Supervised Projects';
      case UserRole.assistant:
        return 'My Assisting Projects';
      case UserRole.user:
      default:
        return 'My Projects';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authState.userModel == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load profile data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final userModel = authState.userModel!;
        final isSupervisorOrAssistant = userModel.role == UserRole.supervisor || 
                                         userModel.role == UserRole.assistant;

        return Scaffold(
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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildAppBar(context),
                    const SizedBox(height: 24),
                    _buildProfileHeader(userModel),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, userModel),
                    const SizedBox(height: 48),
                    
                    // Projects/Teams Section
                    if (isSupervisorOrAssistant)
                      _buildTeamsSection(userModel) // للدكتور والمعيد
                    else
                      _buildProjectsSection(userModel), // للطالب العادي
                    
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, size: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              child: const Icon(Icons.settings, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel userModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
            ),
            child: ClipOval(child: _buildProfileImage(userModel)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  userModel.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getUserInfo(userModel),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserInfo(UserModel userModel) {
    switch (userModel.role) {
      case UserRole.user:
        return '${userModel.bio ?? 'User'}\n${userModel.university ?? 'University not set'}';
      case UserRole.assistant:
        return '${userModel.position ?? 'Assistant'}\n${userModel.department ?? 'Department not set'}';
      case UserRole.supervisor:
        return '${userModel.position ?? 'Supervisor'}\n${userModel.department ?? 'Department not set'}';
    }
  }

  Widget _buildProfileImage(UserModel userModel) {
    const placeholder = Icon(Icons.person, size: 50, color: Color(0xFF1E3A8A));
    const placeholderBg = Color(0xFFDBEAFE);

    Widget withBg(Widget child) =>
        Container(color: placeholderBg, child: child);

    final url = userModel.photoUrl;

    if (url == null || url.isEmpty) return withBg(placeholder);

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => withBg(placeholder),
      );
    }

    if (url.startsWith('assets')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => withBg(placeholder),
      );
    }

    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => withBg(placeholder),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserModel userModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            label: 'Edit',
            bgColor: const Color(0xFFDBEAFE),
            assetPath: 'assets/images/Frame 176.png',
            fallbackIcon: Icons.edit,
            iconPadding: const EdgeInsets.all(8),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    currentName: userModel.fullName,
                    currentBio: userModel.bio ?? '',
                    currentUniversity: userModel.university,
                    currentPosition: userModel.position,
                    currentDepartment: userModel.department,
                    currentImage: userModel.photoUrl ?? '',
                    role: userModel.role,
                  ),
                ),
              );

              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          _buildActionButton(
            label: 'Tasks',
            bgColor: const Color(0xDBFF002A),
            assetPath: 'assets/images/task_icon.png',
            fallbackIcon: Icons.task,
            iconPadding: const EdgeInsets.all(8),
            onTap: () {
              print('Tasks tapped');
            },
          ),
          _buildActionButton(
            label: 'chat bot',
            bgColor: const Color(0xFFA8FF97),
            assetPath: 'assets/images/chatbot_icon.png',
            fallbackIcon: Icons.smart_toy,
            iconPadding: const EdgeInsets.all(12),
            onTap: () {
              print('Chat Bot tapped');
            },
          ),
          _buildActionButton(
            label: 'Posts',
            bgColor: const Color(0x99C69AFE),
            assetPath: 'assets/images/Frame 183.png',
            fallbackIcon: Icons.post_add,
            iconPadding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunityScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color bgColor,
    required String assetPath,
    required IconData fallbackIcon,
    required EdgeInsets iconPadding,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: iconPadding,
              decoration: ShapeDecoration(
                color: bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(fallbackIcon, color: Colors.black87, size: 24),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // قسم المشاريع للطلاب العاديين
  Widget _buildProjectsSection(UserModel userModel) {
    return BlocBuilder<ProjectCubit, ProjectState>(
      builder: (context, state) {
        final userProjects = state.getProjectsByUser(userModel.uid);
        final displayProjects = _showAllProjects
            ? userProjects
            : userProjects.take(2).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - في صف واحد
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Projects',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      if (userProjects.length > 2)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllProjects = !_showAllProjects;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            _showAllProjects ? 'show less' : 'see all',
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProjectScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Explore All Projects →',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (state.status == ProjectStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (userProjects.isEmpty)
                _buildEmptyProjects()
              else
                ...displayProjects.map(
                  (project) => _buildProjectCard(project, userModel),
                ),
            ],
          ),
        );
      },
    );
  }

  // قسم الفرق للدكتور والمعيد
  Widget _buildTeamsSection(UserModel userModel) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        List<TeamModel> teams = [];
        if (state is TeamsLoaded) {
          teams = state.teams;
        }

        final displayTeams = _showAllProjects
            ? teams
            : teams.take(2).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - في صف واحد
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getProjectsSectionTitle(userModel.role),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (teams.length > 2)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllProjects = !_showAllProjects;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        _showAllProjects ? 'show less' : 'see all',
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (state is TeamsLoading)
                const Center(child: CircularProgressIndicator())
              else if (teams.isEmpty)
                _buildEmptyTeams(userModel.role)
              else
                ...displayTeams.map(
                  (team) => _buildTeamCard(team, userModel),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyProjects() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildEmptyTeams(UserRole role) {
    String message = role == UserRole.supervisor 
        ? 'No supervised projects yet' 
        : 'No assisting projects yet';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // كارد المشروع العادي للطلاب
  Widget _buildProjectCard(Project project, UserModel userModel) {
    final isOwner = project.authorId == userModel.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectDetailsScreen(project: project),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 91,
                  height: 97,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFDBEAFE),
                  ),
                  child: project.images.isNotEmpty
                      ? (project.images.first.startsWith('http')
                            ? Image.network(
                                project.images.first,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(project.images.first),
                                fit: BoxFit.cover,
                              ))
                      : const Icon(
                          Icons.business_center,
                          size: 40,
                          color: Color(0xFF1E3A8A),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isOwner) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _handleEditProject(project),
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                TextButton.icon(
                  onPressed: () =>
                      _handleDeleteProject(project.id, project.title),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // كارد الفريق للدكتور والمعيد
  Widget _buildTeamCard(TeamModel team, UserModel userModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailsScreen(
                team: team,
                userRole: userModel.role,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFDBEAFE),
                  ),
                  child: const Center(
                    child: Text(
                      '👥',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.projectName ?? 'No Project',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101727),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF495565),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF2F4F6)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${team.totalMembers} Members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF495565),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.task_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${team.activeProjects * 3} Tasks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF495565),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditProject(Project project) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProjectScreen(project: project),
      ),
    );

    if (result == true && mounted) {
      _loadUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleDeleteProject(String projectId, String projectTitle) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        projectTitle: projectTitle,
        onConfirm: () async {
          await context.read<ProjectCubit>().deleteProject(projectId);
          if (mounted) {
            _loadUserData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Project deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}