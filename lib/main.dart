import 'package:flutter/material.dart';
import 'package:onboard/core/Theme/app_theme.dart';
import 'package:onboard/screens/login_screen.dart';
import 'package:onboard/screens/main_layout_navbar.dart';
import 'package:onboard/screens/onboarding_screen.dart';
import 'package:onboard/screens/varification_email.dart';
import 'package:onboard/screens/welcome_screen.dart';
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
      home: const OnboardingScreen(),
      // home: WelcomeScreen(),
      // // // home: LoginScreen(),
      // // // home: VarificationEmail(),
      // home: MainLayoutNavbar(),
    );
  }
}
