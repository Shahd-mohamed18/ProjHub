import 'package:flutter/material.dart';
import 'package:onboard/screens/login_screen.dart';
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
                    Text(
                      'Welcome To',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      'ProjHub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      'Where Innovation Meets Collaboration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 60),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
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

                    SizedBox(height: 15),

                    CustomWelcomeWidget(
                      title: 'Supervisor',
                      subtitle1: 'manage teams',
                      subtitle2: 'and progress',
                      imagePath:
                          'assets/images/6751dd9a9d57790ad08dd50652e2aacbaac8513b.png',
                      color: Color(0Xff9747FF),
                    ),

                    SizedBox(height: 15),

                    CustomWelcomeWidget(
                      title: 'Assistant',
                      subtitle1: 'support,help,',
                      subtitle2: 'and manage',
                      imagePath:
                          'assets/images/33d002cbe644eae4c317e983ea7ad2655cbd135d.png',
                      color: Color(0xffE9EC4D),
                    ),

                    SizedBox(height: 30),

                    Text(
                      'By Continuing, You Agree Our Terms',
                      style: TextStyle(
                        color: Color.fromARGB(255, 89, 121, 137),
                      ),
                    ),
                    Text(
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
