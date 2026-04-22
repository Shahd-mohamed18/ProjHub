
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/AuthScreens/login_screen.dart';
import 'package:onboard/widgets/custom_welcome_widget.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome To',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const Text(
                      'ProjHub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const Text(
                      'Where Innovation Meets Collaboration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // User (كان Student)
                    GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().setTempRole(UserRole.user);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: CustomWelcomeWidget(
                        title: 'User',
                        subtitle1: 'share projects',
                        subtitle2: 'and collaborate',
                        imagePath: 'assets/images/grade icon.jpg',
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Supervisor (كان Doctor)
                    GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().setTempRole(UserRole.supervisor);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: CustomWelcomeWidget(
                        title: 'Supervisor',
                        subtitle1: 'supervise projects,',
                        subtitle2: 'manage teams',
                        imagePath:
                            'assets/images/6751dd9a9d57790ad08dd50652e2aacbaac8513b.png',
                        color: const Color(0Xff9747FF),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Assistant
                    GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().setTempRole(
                          UserRole.assistant,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: CustomWelcomeWidget(
                        title: 'Assistant',
                        subtitle1: 'support, help,',
                        subtitle2: 'and manage',
                        imagePath:
                            'assets/images/33d002cbe644eae4c317e983ea7ad2655cbd135d.png',
                        color: const Color(0xffE9EC4D),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'By Continuing, You Agree Our Terms',
                      style: TextStyle(
                        color: Color.fromARGB(255, 89, 121, 137),
                      ),
                    ),
                    const Text(
                      '& Privacy Policy',
                      style: TextStyle(
                        color: Color.fromARGB(255, 89, 121, 137),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
