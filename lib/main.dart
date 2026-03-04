import 'package:flutter/material.dart';
import 'package:onboard/providers/project_provider.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onboard/core/Theme/app_theme.dart';
import 'package:onboard/screens/login_screen.dart';
import 'package:onboard/screens/main_layout_navbar.dart';
import 'package:onboard/screens/ProfileScreen/profile_screen.dart';
import 'package:onboard/screens/onboarding_screen.dart';
import 'package:onboard/screens/varification_email.dart';
import 'package:onboard/screens/welcome_screen.dart';

import 'package:onboard/screens/sign_up_screen.dart';
import 'package:onboard/screens/forget_password_screen.dart';

import 'package:onboard/screens/project_details_screen.dart';
import 'package:onboard/screens/add_project_screen.dart';
import 'package:onboard/models/project_model.dart';

import 'package:onboard/screens/sign_up_screen.dart'; 
import 'package:onboard/screens/forget_password_screen.dart'; 
import 'package:onboard/screens/community/community_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// class ProjectProvider extends ChangeNotifier {
//   // نبدأ بقائمة فاضية
//   final List<Project> _projects = [];

//   List<Project> get projects => _projects;

//   void addProject(Project project) {
//     _projects.add(project);
//     notifyListeners();
//   }

//   Project? getProjectById(String id) {
//     try {
//       return _projects.firstWhere((project) => project.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   List<Project> getProjectsByCategory(String category) {
//     if (category == 'All') return _projects;
//     return _projects.where((project) => project.category == category).toList();
//   }

//   List<Project> getProjectsByUser(String userId) {
//     return _projects.where((project) => project.authorId == userId).toList();
//   }

//   void deleteProject(String id) {
//     _projects.removeWhere((project) => project.id == id);
//     notifyListeners();
//   }

//   void updateProject(Project updatedProject) {
//     final index = _projects.indexWhere((project) => project.id == updatedProject.id);
//     if (index != -1) {
//       _projects[index] = updatedProject;
//       notifyListeners();
//     }
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MyApp());
// }



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Onboarding Demo',
        theme: AppTheme.lightTheme,
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/verification': (context) => const VarificationEmail(),
          '/main': (context) => const MainLayoutNavbar(),
          '/profile': (context) => const ProfileScreen(),
          '/forgetpassword': (context) => const ForgetPasswordScreen(),
          '/community': (context) => const CommunityScreen(),

        },
      ),
    );
  }
}
