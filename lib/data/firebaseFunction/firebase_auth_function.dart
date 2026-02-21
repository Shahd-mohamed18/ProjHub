import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onboard/screens/home_screen.dart';
import 'package:onboard/screens/main_layout_navbar.dart';
import 'package:onboard/screens/varification_email.dart';
import 'package:onboard/models/user_model.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthFunction {
  static Future<void> SignUpWithPasswordAndEmail({
    required String email,
    required String password,
    required BuildContext context,
    required String fullName,
    required String university,
    required String faculty,
    required String track,
    String photoUrl = "",
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      ),
    );

    try {
      print('Starting signup...');

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print('User created: ${credential.user!.uid}');

      // ✅ تعديل هنا: إضافة كل البيانات المطلوبة
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'email': email,
        'fullName': fullName,
        'university': university,
        'faculty': faculty,
        'track': track,
        'bio': 'Hello, I am $fullName',
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Data saved to Firestore');

      await credential.user?.sendEmailVerification();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      showSnackBar(context, 'Sign Up Success! Please verify your email.');

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VarificationEmail()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = e.message ?? 'An error occurred.';
      }

      showSnackBar(context, errorMessage);
    } catch (e) {
      print('❌ Error: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      showSnackBar(context, 'Sign up failed: $e');
    }
  }

  // ================ LOGIN =================
  static Future<void> LoginWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      ),
    );

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (credential.user != null && credential.user!.emailVerified) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainLayoutNavbar()),
          (route) => false,
        );
        showSnackBar(context, 'Login Success!');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VarificationEmail()),
        );
        await credential.user?.sendEmailVerification();
        showSnackBar(context, 'Please verify your email first.');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (e.code == 'user-not-found') {
        showSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, 'Wrong password provided.');
      } else {
        showSnackBar(context, e.message ?? 'Login failed');
      }
    }
  }

  // ================ RESET PASSWORD =================
  static Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      FirebaseAuthFunction.showSnackBar(
        context,
        'Password reset link sent! Check your Email',
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(context, 'No user found for that email.');
      } else if (e.code == 'invalid-credential') {
        showSnackBar(context, 'Invalid email or password.');
      } else {
        showSnackBar(context, e.message ?? 'Authentication failed: ${e.code}');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // ================ GET CURRENT USER DATA =================
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      return null;
    }
  }

  // ================ UPDATE PROFILE =================
  static Future<bool> updateUserProfile({
    required String name,
    required String bio,
    required String university,
    String? imagePath,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      Map<String, dynamic> updateData = {
        'fullName': name,
        'bio': bio,
        'university': university,
      };

      // ✅ لو في صورة جديدة (مش URL ومش assets)
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http') &&
          !imagePath.startsWith('assets')) {
        updateData['photoUrl'] = imagePath;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      return true;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return false;
    }
  }

  // ================ SHOW SNACKBAR =================
  static void showSnackBar(BuildContext context, String Message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Message),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}