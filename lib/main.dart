import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/cubits/chat/chat_cubit.dart';
import 'package:onboard/core/theme/app_theme.dart';
import 'package:onboard/screens/AuthScreens/Sign_up_screen.dart';
import 'package:onboard/screens/AuthScreens/login_screen.dart';
import 'package:onboard/screens/ProfileScreen/profile_screen.dart';

import 'package:onboard/screens/main_layout_navbar.dart';

import 'package:onboard/screens/onboarding_screen.dart';
import 'package:onboard/screens/projectScreens/add_project_screen.dart';
import 'package:onboard/screens/projectScreens/project_screen.dart';
import 'package:onboard/screens/AuthScreens/varification_email.dart';

import 'package:onboard/screens/AuthScreens/welcome_screen.dart';

import 'package:onboard/screens/AuthScreens/forget_password_screen.dart';
import 'package:onboard/screens/community/community_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()..initialize()),
        BlocProvider<ProjectCubit>(
          create: (context) => ProjectCubit()..loadProjects(),
        ),
        BlocProvider<ChatCubit>(create: (context) => ChatCubit()),
      ],
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
          '/projects': (context) => const ProjectScreen(),
          '/add-project': (context) => const AddProjectScreen(),
        },
      ),
    );
  }
}
