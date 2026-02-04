// import 'package:flutter/material.dart';
// import 'package:onboard/screens/Sign_up_screen.dart';
// import 'package:onboard/screens/forget_password_screen.dart';
// import 'package:onboard/validation/form_validation.dart';
// import 'package:onboard/widgets/custom_form_field_widget.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

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
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 15),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Text(
//                     'Welcome Back',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
//                   ),
//                   Text(
//                     'To ProjHub ',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
//                   ),

//                   SizedBox(height: 50),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Email',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   CustomFormFieldWidget(
//                     textController: emailController,
//                     text: 'Enter your email',
//                     icon: Icon(Icons.email, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.emailValidation,
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Password',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   CustomFormFieldWidget(
//                     textController: passwordController,
//                     text: 'Enter your password',
//                     icon: Icon(Icons.lock, color: Color(0xff7E9FCA)),
//                     isObs: true,
//                     valuValidation: FormValidation.passwordValidation,
//                   ),
//                   SizedBox(height: 20),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (Context) => ForgetPasswordScreen(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       alignment: Alignment.topRight,
//                       child: Text(
//                         'Forget Password?',
//                         style: TextStyle(color: Color(0xFF3B82F6)),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 100),
//                   ElevatedButton(
//                     // onPressed: () async {
//                     //   if (_formKey.currentState!.validate()) {
//                     //     FirebaseAuthFunction.LoginWithEmailAndPassword(
//                     //       email: emailController.text,
//                     //       password: passwordController.text,
//                     //       context: context,
//                     //     );
//                     //   }
//                     // },
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 100,
//                         vertical: 10,
//                       ),
//                       backgroundColor: Color(0xFF1E3A8A),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       'LOGIN',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Don't Have An Account?",
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => SignUpScreen()),
//                       );
//                     },
//                     child: Text(
//                       ' SIGN UP',
//                       style: TextStyle(
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1E3A8A),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:onboard/data/firebaseFunction/firebase_auth_function.dart';
import 'package:onboard/screens/Sign_up_screen.dart';
import 'package:onboard/screens/forget_password_screen.dart';
import 'package:onboard/validation/form_validation.dart';
import 'package:onboard/widgets/custom_form_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 15),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  const Text(
                    'To ProjHub',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),

                  const SizedBox(height: 50),

                  // Email
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomFormFieldWidget(
                    textController: emailController,
                    text: 'Enter your email',
                    icon: const Icon(Icons.email, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.emailValidation,
                  ),

                  const SizedBox(height: 20),

                  // Password
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomFormFieldWidget(
                    textController: passwordController,
                    text: 'Enter your password',
                    icon: const Icon(Icons.lock, color: Color(0xff7E9FCA)),
                    isObs: true,
                    valuValidation: FormValidation.passwordValidation,
                  ),

                  const SizedBox(height: 20),

                  // Forget Password
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Forget Password?',
                        style: TextStyle(color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 130),

                  // Login Button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        FirebaseAuthFunction.LoginWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                          context: context,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 12,
                      ),
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Don't Have An Account?",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      ' SIGN UP',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
