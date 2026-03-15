// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onboard/models/user_model.dart';

// part 'auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(const AuthState());

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   StreamSubscription? _authSubscription;

//   // تخزين الدور المؤقت (للاستخدام في الـ sign up)
//   UserRole? _tempSelectedRole;

//   void setTempRole(UserRole role) {
//     _tempSelectedRole = role;
//   }

//   UserRole? getTempRole() => _tempSelectedRole;

//   void initialize() {
//     _authSubscription = _auth.authStateChanges().listen((User? user) async {
//       if (user != null) {
//         if (user.emailVerified) {
//           await _loadUserData(user);
//         } else {
//           emit(state.copyWith(
//             status: AuthStatus.unauthenticated,
//             firebaseUser: user,
//             userModel: null,
//           ));
//         }
//       } else {
//         emit(state.copyWith(
//           status: AuthStatus.unauthenticated,
//           firebaseUser: null,
//           userModel: null,
//         ));
//       }
//     });
//   }

//   Future<void> _loadUserData(User user) async {
//     try {
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         final userModel = UserModel.fromMap(user.uid, doc.data()!);
//         emit(state.copyWith(
//           status: AuthStatus.authenticated,
//           firebaseUser: user,
//           userModel: userModel,
//         ));
//       } else {
//         await user.delete();
//         emit(state.copyWith(status: AuthStatus.unauthenticated));
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: 'Error loading user data: $e',
//       ));
//     }
//   }

//   // Sign up for students
//   Future<void> signUpStudent({
//     required String email,
//     required String password,
//     required String fullName,
//     required String university,
//     required String faculty,
//     required String track,
//     String? photoUrl,
//     required BuildContext context,
//   }) async {
//     emit(state.copyWith(status: AuthStatus.loading));

//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = credential.user!;
      
//       final userModel = UserModel(
//         uid: user.uid,
//         email: email,
//         fullName: fullName,
//         role: UserRole.student,
//         university: university,
//         faculty: faculty,
//         track: track,
//         photoUrl: photoUrl,
//         bio: 'Hello, I am $fullName',
//       );

//       await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
//       await user.sendEmailVerification();

//       emit(state.copyWith(
//         status: AuthStatus.unauthenticated,
//         firebaseUser: user,
//         userModel: null,
//       ));

//       _showSnackBar(context, 'Sign Up Success! Please verify your email.');
      
//       Navigator.pushReplacementNamed(context, '/verification');
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Sign up failed: $e', context);
//     }
//   }

//   // Sign up for doctors/assistants
//   Future<void> signUpEducator({
//     required String email,
//     required String password,
//     required String fullName,
//     required UserRole role,
//     required String position,
//     required String department,
//     String? photoUrl,
//     required BuildContext context,
//   }) async {
//     emit(state.copyWith(status: AuthStatus.loading));

//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = credential.user!;
      
//       final userModel = UserModel(
//         uid: user.uid,
//         email: email,
//         fullName: fullName,
//         role: role,
//         position: position,
//         department: department,
//         photoUrl: photoUrl,
//         bio: 'Hello, I am $fullName, $position at $department',
//       );

//       await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
//       await user.sendEmailVerification();

//       emit(state.copyWith(
//         status: AuthStatus.unauthenticated,
//         firebaseUser: user,
//         userModel: null,
//       ));

//       _showSnackBar(context, 'Sign Up Success! Please verify your email.');
      
//       Navigator.pushReplacementNamed(context, '/verification');
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Sign up failed: $e', context);
//     }
//   }

//   // Login
//   Future<void> login({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     emit(state.copyWith(status: AuthStatus.loading));

//     try {
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = credential.user!;

//       if (user.emailVerified) {
//         await _loadUserData(user);
//         _showSnackBar(context, 'Login Success!');
//         Navigator.pushReplacementNamed(context, '/main');
//       } else {
//         emit(state.copyWith(
//           status: AuthStatus.unauthenticated,
//           firebaseUser: user,
//         ));
//         await user.sendEmailVerification();
//         _showSnackBar(context, 'Please verify your email first.');
//         Navigator.pushReplacementNamed(context, '/verification');
//       }
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Login failed: $e', context);
//     }
//   }

//   // دالة تحديث البروفايل
//   Future<void> updateUserProfile({
//     required String fullName,
//     required String bio,
//     String? university,
//     String? position,
//     String? department,
//     String? photoUrl,
//     required BuildContext context,
//   }) async {
//     emit(state.copyWith(status: AuthStatus.loading));

//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('No user logged in');

//       final updateData = <String, dynamic>{
//         'fullName': fullName,
//         'bio': bio,
//       };

//       if (state.userModel?.role == UserRole.student) {
//         if (university != null) updateData['university'] = university;
//       } else {
//         if (position != null) updateData['position'] = position;
//         if (department != null) updateData['department'] = department;
//       }

//       if (photoUrl != null && 
//           photoUrl.isNotEmpty && 
//           !photoUrl.startsWith('http') && 
//           photoUrl != state.userModel?.photoUrl) {
//         updateData['photoUrl'] = photoUrl;
//       }

//       await _firestore.collection('users').doc(user.uid).update(updateData);
      
//       await _loadUserData(user);
      
//       _showSnackBar(context, 'Profile updated successfully!');
//     } catch (e) {
//       _handleError('Failed to update profile: $e', context);
//     }
//   }

//   // Logout
//   Future<void> logout() async {
//     await _auth.signOut();
//     _tempSelectedRole = null;
//     emit(state.copyWith(status: AuthStatus.unauthenticated));
//   }

//   // Reset password
//   Future<void> resetPassword({
//     required String email,
//     required BuildContext context,
//   }) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       _showSnackBar(context, 'Password reset link sent! Check your Email');
//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Failed to send reset email: $e', context);
//     }
//   }

//   // Resend verification email
//   Future<void> resendVerificationEmail(BuildContext context) async {
//     try {
//       await state.firebaseUser?.sendEmailVerification();
//       _showSnackBar(
//         context,
//         'Verification link sent to your email. Check inbox or spam.',
//       );
//     } catch (e) {
//       _handleError('Error sending email: $e', context);
//     }
//   }

//   // Check email verification
//   Future<void> checkEmailVerification(BuildContext context) async {
//     await state.firebaseUser?.reload();
//     final user = _auth.currentUser;
    
//     if (user != null && user.emailVerified) {
//       await _loadUserData(user);
//       if (context.mounted) {
//         Navigator.pushReplacementNamed(context, '/main');
//       }
//     }
//   }

//   void _handleAuthError(FirebaseAuthException e, BuildContext context) {
//     String message;
//     switch (e.code) {
//       case 'weak-password':
//         message = 'The password provided is too weak.';
//         break;
//       case 'email-already-in-use':
//         message = 'An account already exists with that email.';
//         break;
//       case 'user-not-found':
//         message = 'No user found for that email.';
//         break;
//       case 'wrong-password':
//         message = 'Wrong password provided.';
//         break;
//       case 'invalid-credential':
//         message = 'Invalid email or password.';
//         break;
//       default:
//         message = e.message ?? 'An error occurred.';
//     }
    
//     emit(state.copyWith(
//       status: AuthStatus.error,
//       errorMessage: message,
//     ));
    
//     _showSnackBar(context, message);
//   }

//   void _handleError(String message, BuildContext context) {
//     emit(state.copyWith(
//       status: AuthStatus.error,
//       errorMessage: message,
//     ));
//     _showSnackBar(context, message);
//   }

//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   @override
//   Future<void> close() {
//     _authSubscription?.cancel();
//     return super.close();
//   }
// }





import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authSubscription;

  // تخزين الدور المؤقت (للاستخدام في الـ sign up)
  UserRole? _tempSelectedRole;

  void setTempRole(UserRole role) {
    _tempSelectedRole = role;
  }

  UserRole? getTempRole() => _tempSelectedRole;

  void initialize() {
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (user.emailVerified) {
          await _loadUserData(user);
        } else {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            firebaseUser: user,
            userModel: null,
          ));
        }
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          firebaseUser: null,
          userModel: null,
        ));
      }
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(user.uid, doc.data()!);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          firebaseUser: user,
          userModel: userModel,
        ));
      } else {
        await user.delete();
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error loading user data: $e',
      ));
    }
  }

  // Sign up for users (كانت students)
  Future<void> signUpUser({
    required String email,
    required String password,
    required String fullName,
    required String university,
    required String faculty,
    required String track,
    String? photoUrl,
    required BuildContext context,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        fullName: fullName,
        role: UserRole.user,
        university: university,
        faculty: faculty,
        track: track,
        photoUrl: photoUrl,
        bio: 'Hello, I am $fullName',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      await user.sendEmailVerification();

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        firebaseUser: user,
        userModel: null,
      ));

      _showSnackBar(context, 'Sign Up Success! Please verify your email.');
      
      Navigator.pushReplacementNamed(context, '/verification');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Sign up failed: $e', context);
    }
  }

  // Sign up for supervisors/assistants (كانت doctors/assistants)
  Future<void> signUpEducator({
    required String email,
    required String password,
    required String fullName,
    required UserRole role, // يمكن أن يكون supervisor أو assistant
    required String position,
    required String department,
    String? photoUrl,
    required BuildContext context,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        fullName: fullName,
        role: role,
        position: position,
        department: department,
        photoUrl: photoUrl,
        bio: 'Hello, I am $fullName, $position at $department',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      await user.sendEmailVerification();

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        firebaseUser: user,
        userModel: null,
      ));

      _showSnackBar(context, 'Sign Up Success! Please verify your email.');
      
      Navigator.pushReplacementNamed(context, '/verification');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Sign up failed: $e', context);
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      if (user.emailVerified) {
        await _loadUserData(user);
        _showSnackBar(context, 'Login Success!');
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          firebaseUser: user,
        ));
        await user.sendEmailVerification();
        _showSnackBar(context, 'Please verify your email first.');
        Navigator.pushReplacementNamed(context, '/verification');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Login failed: $e', context);
    }
  }

  // دالة تحديث البروفايل
  Future<void> updateUserProfile({
    required String fullName,
    required String bio,
    String? university,
    String? position,
    String? department,
    String? photoUrl,
    required BuildContext context,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final updateData = <String, dynamic>{
        'fullName': fullName,
        'bio': bio,
      };

      if (state.userModel?.role == UserRole.user) {
        if (university != null) updateData['university'] = university;
      } else {
        if (position != null) updateData['position'] = position;
        if (department != null) updateData['department'] = department;
      }

      if (photoUrl != null && 
          photoUrl.isNotEmpty && 
          !photoUrl.startsWith('http') && 
          photoUrl != state.userModel?.photoUrl) {
        updateData['photoUrl'] = photoUrl;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      await _loadUserData(user);
      
      _showSnackBar(context, 'Profile updated successfully!');
    } catch (e) {
      _handleError('Failed to update profile: $e', context);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _tempSelectedRole = null;
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackBar(context, 'Password reset link sent! Check your Email');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Failed to send reset email: $e', context);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      await state.firebaseUser?.sendEmailVerification();
      _showSnackBar(
        context,
        'Verification link sent to your email. Check inbox or spam.',
      );
    } catch (e) {
      _handleError('Error sending email: $e', context);
    }
  }

  // Check email verification
  Future<void> checkEmailVerification(BuildContext context) async {
    await state.firebaseUser?.reload();
    final user = _auth.currentUser;
    
    if (user != null && user.emailVerified) {
      await _loadUserData(user);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  void _handleAuthError(FirebaseAuthException e, BuildContext context) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with that email.';
        break;
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password.';
        break;
      default:
        message = e.message ?? 'An error occurred.';
    }
    
    emit(state.copyWith(
      status: AuthStatus.error,
      errorMessage: message,
    ));
    
    _showSnackBar(context, message);
  }

  void _handleError(String message, BuildContext context) {
    emit(state.copyWith(
      status: AuthStatus.error,
      errorMessage: message,
    ));
    _showSnackBar(context, message);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}