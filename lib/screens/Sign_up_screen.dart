import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onboard/data/firebaseFunction/firebase_auth_function.dart';
import 'package:onboard/screens/login_screen.dart';
import 'package:onboard/validation/form_validation.dart';
import 'package:onboard/widgets/custom_form_field_widget.dart';
import 'package:onboard/widgets/image_picker_widget.dart';

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
  final universtyController = TextEditingController();
  final facultyController = TextEditingController();
  final trackController = TextEditingController();

  XFile? _imageFile;

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _onImageSelected(XFile? image) {
    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: Text(
      //       'Sign Up',
      //       style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 64),
              child: Column(
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // SizedBox(height: 15),
                  ImagePickerWidget(
                    onImageSelected: _onImageSelected,
                    radius: 80.0,
                    cameraIconSize: 24.0,
                    backgroundColor: Color(0xff7E9FCA),
                    iconColor: Color(0xFF1E3A8A),
                    initialImagePath: _imageFile?.path,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    textController: nameController,
                    text: 'Full Name',
                    icon: Icon(Icons.person, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.nameBloodValidation,
                  ),

                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    textController: emailController,
                    text: 'Email',
                    icon: Icon(Icons.email, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.emailValidation,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Instituation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    textController: universtyController,
                    text: 'Enter your university',
                    icon: Icon(Icons.school, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.nameBloodValidation,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Faculty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    textController: facultyController,
                    text: 'Enter your faculty',
                    icon: Icon(Icons.school_outlined, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.nameBloodValidation,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Track',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    textController: trackController,
                    text: 'Enter your Track',
                    icon: Icon(Icons.work, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.nameBloodValidation,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    textController: passwordController,
                    text: 'password',
                    icon: Icon(Icons.lock, color: Color(0xff7E9FCA)),
                    valuValidation: FormValidation.passwordValidation,
                    isObs: true,
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomFormFieldWidget(
                    isObs: true,
                    textController: confirmPasswordController,
                    text: 'Confirm Password',
                    icon: Icon(Icons.lock_outline, color: Color(0xff7E9FCA)),
                    valuValidation: (value) =>
                        FormValidation.confirmPasswordValidation(
                          value,
                          passwordController.text,
                        ),
                  ),

                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      await FirebaseAuthFunction.SignUpWithPasswordAndEmail(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        fullName: nameController.text.trim(),
                        university: universtyController.text.trim(),
                        faculty: facultyController.text.trim(),
                        track: trackController.text.trim(),
                        photoUrl: _imageFile?.path ?? "",
                        context: context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 12,
                      ),
                      backgroundColor: Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Already have An account? ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
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
        ),
      ),
    );
  }
}
