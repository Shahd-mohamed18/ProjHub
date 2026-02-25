import 'package:flutter/material.dart';
import 'package:onboard/core/Theme/app_theme.dart';
import 'package:onboard/screens/login_screen.dart';
import 'package:onboard/screens/main_layout_navbar.dart';
import 'package:onboard/screens/ProfileScreen/profile_screen.dart';
import 'package:onboard/screens/onboarding_screen.dart';
import 'package:onboard/screens/varification_email.dart';
import 'package:onboard/screens/welcome_screen.dart';
import 'package:onboard/screens/sign_up_screen.dart'; 
import 'package:onboard/screens/forget_password_screen.dart'; 
import 'package:onboard/screens/community/community_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}