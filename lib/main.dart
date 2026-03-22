import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/cubits/project/project_cubit.dart';
import 'package:onboard/cubits/chat/chat_cubit.dart';
import 'package:onboard/cubits/teams/teams_cubit.dart';
import 'package:onboard/cubits/supervisor/supervisor_task_cubit.dart';
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
import 'package:onboard/screens/supervisorScreens/all_tasks_screen.dart';
import 'package:onboard/repositories/mock_task_repository.dart';
import 'package:onboard/screens/supervisorScreens/create_task_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..initialize(),
        ),
        BlocProvider<ProjectCubit>(
          create: (_) => ProjectCubit()..loadProjects(),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(),
        ),
        // ✅ TeamsCubit الأول عشان SupervisorTaskCubit يحتاجه
        BlocProvider<TeamsCubit>(
          create: (_) => TeamsCubit(),
        ),
        // ✅ SupervisorTaskCubit بياخد TeamsCubit بدل MockTeamRepository
        BlocProvider<SupervisorTaskCubit>(
          create: (context) => SupervisorTaskCubit(
            MockTaskRepository(),
            context.read<TeamsCubit>(), // ✅ بياخده من الـ context
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Onboarding Demo',
        theme: AppTheme.lightTheme,
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/welcome': (_) => const WelcomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/verification': (_) => const VarificationEmail(),
          '/main': (_) => const MainLayoutNavbar(),
          '/profile': (_) => const ProfileScreen(),
          '/forgetpassword': (_) => const ForgetPasswordScreen(),
          '/community': (_) => const CommunityScreen(),
          '/projects': (_) => const ProjectScreen(),
          '/add-project': (_) => const AddProjectScreen(),
          '/all_tasks': (context) => const AllTasksScreen(),
          //'/create_task': (context) => const CreateTaskScreen(),
        },
      ),
    );
  }
}