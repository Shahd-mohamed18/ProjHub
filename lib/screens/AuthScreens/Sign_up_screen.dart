// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:onboard/data/firebaseFunction/firebase_auth_function.dart';
// import 'package:onboard/screens/login_screen.dart';
// import 'package:onboard/validation/form_validation.dart';
// import 'package:onboard/widgets/Profile/custom_form_field_widget.dart';
// import 'package:onboard/widgets/Profile/image_picker_widget.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final passwordController = TextEditingController();
//   final emailController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   final nameController = TextEditingController();
//   final universtyController = TextEditingController();
//   final facultyController = TextEditingController();
//   final trackController = TextEditingController();

//   XFile? _imageFile;

//   @override
//   void dispose() {
//     passwordController.dispose();
//     emailController.dispose();
//     confirmPasswordController.dispose();
//     nameController.dispose();
//     super.dispose();
//   }

//   void _onImageSelected(XFile? image) {
//     setState(() {
//       _imageFile = image;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Center(
//       //     child: Text(
//       //       'Sign Up',
//       //       style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//       //     ),
//       //   ),
//       // ),
//       body: Container(
//         decoration: const BoxDecoration(
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
//           child: Form(
//             key: _formKey,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 64),
//               child: Column(
//                 children: [
//                   Text(
//                     'Create Account',
//                     style: TextStyle(
//                       fontSize: 30,
//                       fontFamily: 'Roboto',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   // SizedBox(height: 15),
//                   ImagePickerWidget(
//                     onImageSelected: _onImageSelected,
//                     radius: 80.0,
//                     cameraIconSize: 24.0,
//                     backgroundColor: Color(0xff7E9FCA),
//                     iconColor: Color(0xFF1E3A8A),
//                     initialImagePath: _imageFile?.path,
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Full Name',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     textController: nameController,
//                     text: 'Full Name',
//                     icon: Icon(Icons.person, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.nameBloodValidation,
//                   ),

//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Email',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     textController: emailController,
//                     text: 'Email',
//                     icon: Icon(Icons.email, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.emailValidation,
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Instituation',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     textController: universtyController,
//                     text: 'Enter your university',
//                     icon: Icon(Icons.school, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.nameBloodValidation,
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Faculty',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     textController: facultyController,
//                     text: 'Enter your faculty',
//                     icon: Icon(Icons.school_outlined, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.nameBloodValidation,
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Track',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     textController: trackController,
//                     text: 'Enter your Track',
//                     icon: Icon(Icons.work, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.nameBloodValidation,
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Password',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     textController: passwordController,
//                     text: 'password',
//                     icon: Icon(Icons.lock, color: Color(0xff7E9FCA)),
//                     valuValidation: FormValidation.passwordValidation,
//                     isObs: true,
//                   ),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     alignment: Alignment.centerLeft,
//                     child: const Text(
//                       'Confirm Password',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   CustomFormFieldWidget(
//                     isObs: true,
//                     textController: confirmPasswordController,
//                     text: 'Confirm Password',
//                     icon: Icon(Icons.lock_outline, color: Color(0xff7E9FCA)),
//                     valuValidation: (value) =>
//                         FormValidation.confirmPasswordValidation(
//                           value,
//                           passwordController.text,
//                         ),
//                   ),

//                   SizedBox(height: 50),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (!_formKey.currentState!.validate()) {
//                         return;
//                       }

//                       await FirebaseAuthFunction.SignUpWithPasswordAndEmail(
//                         email: emailController.text.trim(),
//                         password: passwordController.text.trim(),
//                         fullName: nameController.text.trim(),
//                         university: universtyController.text.trim(),
//                         faculty: facultyController.text.trim(),
//                         track: trackController.text.trim(),
//                         photoUrl: _imageFile?.path ?? "",
//                         context: context,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 100,
//                         vertical: 12,
//                       ),
//                       backgroundColor: Color(0xFF1E3A8A),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: Text(
//                       'SIGN UP',
//                       style: TextStyle(color: Colors.white, fontSize: 22),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     "Already have An account? ",
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                     },
//                     child: Text(
//                       ' LOGIN',
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onboard/cubits/auth/auth_cubit.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/screens/AuthScreens/login_screen.dart';

import 'package:onboard/validation/form_validation.dart';
import 'package:onboard/widgets/Profile/custom_form_field_widget.dart';
import 'package:onboard/widgets/Profile/image_picker_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // Student fields
  final universityController = TextEditingController();
  final facultyController = TextEditingController();
  final trackController = TextEditingController();

  // Educator fields
  final positionController = TextEditingController();
  final departmentController = TextEditingController();

  late UserRole _selectedRole;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    // ✅ جلب الدور المحفوظ من AuthCubit
    final authCubit = context.read<AuthCubit>();
    final tempRole = authCubit.getTempRole();
    _selectedRole = tempRole ?? UserRole.student;
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    universityController.dispose();
    facultyController.dispose();
    trackController.dispose();
    positionController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  void _onImageSelected(XFile? image) {
    setState(() {
      _imageFile = image;
    });
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();

    if (_selectedRole == UserRole.student) {
      authCubit.signUpStudent(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: nameController.text.trim(),
        university: universityController.text.trim(),
        faculty: facultyController.text.trim(),
        track: trackController.text.trim(),
        photoUrl: _imageFile?.path,
        context: context,
      );
    } else {
      authCubit.signUpEducator(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: nameController.text.trim(),
        role: _selectedRole,
        position: positionController.text.trim(),
        department: departmentController.text.trim(),
        photoUrl: _imageFile?.path,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد نص الدور للعرض
    String roleText = '';
    if (_selectedRole == UserRole.student) {
      roleText = 'Student';
    } else if (_selectedRole == UserRole.doctor) {
      roleText = 'Doctor';
    } else {
      roleText = 'Assistant';
    }

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
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Error')),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 64,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ImagePickerWidget(
                        onImageSelected: _onImageSelected,
                        radius: 80.0,
                        cameraIconSize: 24.0,
                        backgroundColor: const Color(0xff7E9FCA),
                        iconColor: const Color(0xFF1E3A8A),
                        initialImagePath: _imageFile?.path,
                      ),
                      const SizedBox(height: 10),

                      // ✅ عرض الدور فقط بدون اختيار
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getRoleColor(
                                  _selectedRole,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getRoleIcon(_selectedRole),
                                color: _getRoleColor(_selectedRole),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Role',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    roleText,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Common fields
                      _buildField(
                        label: 'Full Name',
                        controller: nameController,
                        icon: Icons.person,
                        validation: FormValidation.nameBloodValidation,
                      ),

                      _buildField(
                        label: 'Email',
                        controller: emailController,
                        icon: Icons.email,
                        validation: FormValidation.emailValidation,
                      ),

                      // Role-specific fields
                      if (_selectedRole == UserRole.student) ...[
                        _buildField(
                          label: 'University',
                          controller: universityController,
                          icon: Icons.school,
                          validation: FormValidation.nameBloodValidation,
                        ),
                        _buildField(
                          label: 'Faculty',
                          controller: facultyController,
                          icon: Icons.school_outlined,
                          validation: FormValidation.nameBloodValidation,
                        ),
                        _buildField(
                          label: 'Track',
                          controller: trackController,
                          icon: Icons.work,
                          validation: FormValidation.nameBloodValidation,
                        ),
                      ] else ...[
                        _buildField(
                          label: _selectedRole == UserRole.doctor
                              ? 'Position'
                              : 'Role',
                          controller: positionController,
                          icon: Icons.badge,
                          validation: FormValidation.nameBloodValidation,
                        ),
                        _buildField(
                          label: 'Department',
                          controller: departmentController,
                          icon: Icons.business,
                          validation: FormValidation.nameBloodValidation,
                        ),
                      ],

                      _buildField(
                        label: 'Password',
                        controller: passwordController,
                        icon: Icons.lock,
                        isObscure: true,
                        validation: FormValidation.passwordValidation,
                      ),

                      _buildField(
                        label: 'Confirm Password',
                        controller: confirmPasswordController,
                        icon: Icons.lock_outline,
                        isObscure: true,
                        validation: (value) =>
                            FormValidation.confirmPasswordValidation(
                              value,
                              passwordController.text,
                            ),
                      ),

                      const SizedBox(height: 50),

                      ElevatedButton(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : _handleSignUp,
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
                        child: state.status == AuthStatus.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Already have An account? ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          ' LOGIN',
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
            );
          },
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const Color(0xff7E9FCA);
      case UserRole.assistant:
        return const Color(0xffE9EC4D);
      case UserRole.doctor:
        return const Color(0Xff9747FF);
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.assistant:
        return Icons.assistant;
      case UserRole.doctor:
        return Icons.medical_services;
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validation,
    bool isObscure = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 5),
        CustomFormFieldWidget(
          textController: controller,
          text: 'Enter your $label',
          icon: Icon(icon, color: const Color(0xff7E9FCA)),
          valuValidation: validation,
          isObs: isObscure,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
