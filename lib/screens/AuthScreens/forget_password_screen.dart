// import 'package:flutter/material.dart';

// import 'package:onboard/data/firebaseFunction/firebase_auth_function.dart';
// import 'package:onboard/validation/form_validation.dart';
// import 'package:onboard/widgets/Profile/custom_form_field_widget.dart';

// class ForgetPasswordScreen extends StatefulWidget {
//   const ForgetPasswordScreen({super.key});

//   @override
//   State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
// }

// class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xffF8FAFC), Color(0xffE2E8F0), Color(0xffB6C6D6)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Back
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.arrow_back),
//                       SizedBox(width: 6),
//                       Text('Back to Login', style: TextStyle(fontSize: 25)),
//                     ],
//                   ),
//                 ),

//                 const Spacer(),

//                 // Center Content
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Icon Circle
//                       Container(
//                         width: 90,
//                         height: 90,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 15,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.mail_outline,
//                           size: 40,
//                           color: Colors.black,
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       const Text(
//                         'enter your email to\nreceive new password',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 14, color: Colors.black54),
//                       ),

//                       const SizedBox(height: 30),

//                       // Email Label
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Email',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 6),

//                       CustomFormFieldWidget(
//                         textController: emailController,
//                         text: 'your.email@example.com',
//                         icon: const Icon(Icons.email_outlined),
//                         valuValidation: FormValidation.emailValidation,
//                       ),

//                       const SizedBox(height: 30),

//                       // Send Button
//                       SizedBox(
//                         width: 140,
//                         height: 44,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (_formKey.currentState!.validate()) {
//                               FirebaseAuthFunction.resetPassword(
//                                 email: emailController.text.trim(),
//                                 context: context,
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff1E3A8A),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Send',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Spacer(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/validation/form_validation.dart';
import 'package:onboard/widgets/Profile/custom_form_field_widget.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // ✅ عشان ياخد كل المساحة
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 6),
                      Text('Back to Login', style: TextStyle(fontSize: 25)),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Content
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state.status == AuthStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage ?? 'Error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon Circle
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mail_outline,
                              size: 40,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Enter your email to receive a password reset link',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),

                          const SizedBox(height: 30),

                          // Email Label
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          CustomFormFieldWidget(
                            textController: emailController,
                            text: 'your.email@example.com',
                            icon: const Icon(Icons.email_outlined),
                            valuValidation: FormValidation.emailValidation,
                          ),

                          const SizedBox(height: 30),

                          // Send Button
                          SizedBox(
                            width: 140,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: state.status == AuthStatus.loading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().resetPassword(
                                              email: emailController.text.trim(),
                                              context: context,
                                            );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1E3A8A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.status == AuthStatus.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : const Text(
                                      'Send',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
