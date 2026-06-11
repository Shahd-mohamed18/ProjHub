// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:onboard/models/user_model.dart';
// import 'package:onboard/services/api_service.dart';

// part 'auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(const AuthState());

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ApiService _apiService = ApiService();
//   StreamSubscription? _authSubscription;

//   UserRole? _tempSelectedRole;
//   bool _isSyncing = false;
//   Timer? _syncDebounceTimer;

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
//           emit(
//             state.copyWith(
//               status: AuthStatus.unauthenticated,
//               firebaseUser: user,
//               userModel: null,
//             ),
//           );
//         }
//       } else {
//         emit(
//           state.copyWith(
//             status: AuthStatus.unauthenticated,
//             firebaseUser: null,
//             userModel: null,
//           ),
//         );
//       }
//     });
//   }

//   Future<void> _syncUserWithDebounce(UserModel userModel) async {
//     _syncDebounceTimer?.cancel();
//     if (_isSyncing) return;
//     _syncDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
//       if (!_isSyncing) {
//         _isSyncing = true;
//         await _apiService.syncUserToBackend(userModel);
//         _isSyncing = false;
//       }
//     });
//   }




//   Future<String?> _fetchAndUpdateUserImage(String userId) async {
//     try {
//       final imageUrl = await _apiService.getUserProfileImageUrl(userId);
//       if (imageUrl != null && imageUrl.isNotEmpty) {
//         await _firestore.collection('users').doc(userId).update({
//           'photoUrl': imageUrl,
//         });
//         print('--------- Updated user photoUrl in Firestore: $imageUrl');
//         return imageUrl;
//       } else {
      
//         final foundUrl = await ApiService.findImageUrl(userId);
//         if (foundUrl != null) {
//           await _firestore.collection('users').doc(userId).update({
//             'photoUrl': foundUrl,
//           });
//           print('--------- Found and saved image URL: $foundUrl');
//           return foundUrl;
//         }
//       }
//     } catch (e) {
//       print('--------- Failed to fetch user image: $e');
//     }
//     return null;
//   }


//   Future<void> signUpUserWithImage({
//     required String email,
//     required String password,
//     required String fullName,
//     required String university,
//     required String faculty,
//     required String track,
//     File? profileImage,
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
//         role: UserRole.user,
//         university: university,
//         faculty: faculty,
//         track: track,
//         photoUrl: null,
//         bio: 'Hello, I am $fullName',
//       );

//       await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

//       if (profileImage != null) {
//         final syncResult = await _apiService.syncUserWithImageToBackend(
//           user: userModel,
//           imageFile: profileImage,
//         );

//         if (syncResult != null && syncResult['success'] == true) {
//           String? finalImageUrl = syncResult['imageUrl'];

        
//           if (finalImageUrl == null || finalImageUrl.isEmpty) {
            
//             final fileName = profileImage.path.split('/').last;
//             String extension = 'jpg';
//             if (fileName.contains('.')) {
//               extension = fileName.split('.').last.toLowerCase();
//             }
//             finalImageUrl = ApiService.buildProfileImageUrl(
//               user.uid,
//               extension: extension,
//             );
//             print(
//               '--------- Built image URL with extension $extension: $finalImageUrl',
//             );
//           }

//           if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
//             await _firestore.collection('users').doc(user.uid).update({
//               'photoUrl': finalImageUrl,
//             });
//             print('--------- Saved image URL to Firestore: $finalImageUrl');
//           }
//         }
//       } else {
//         await _apiService.syncUserToBackend(userModel);
//       }

//       await user.sendEmailVerification();

//       emit(
//         state.copyWith(
//           status: AuthStatus.unauthenticated,
//           firebaseUser: user,
//           userModel: null,
//         ),
//       );

//       _showSnackBar(context, 'Sign Up Success! Please verify your email.');
//       if (context.mounted) {
//         Navigator.pushReplacementNamed(context, '/verification');
//       }
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Sign up failed: $e', context);
//     }
//   }

  
//   Future<void> signUpEducatorWithImage({
//     required String email,
//     required String password,
//     required String fullName,
//     required UserRole role,
//     required String position,
//     required String department,
//     File? profileImage,
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
//         photoUrl: null,
//         bio: 'Hello, I am $fullName, $position at $department',
//         university: department,
//         faculty: position,
//         track: 'Management',
//       );

//       await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

//       if (profileImage != null) {
//         final syncResult = await _apiService.syncUserWithImageToBackend(
//           user: userModel,
//           imageFile: profileImage,
//         );

//         if (syncResult != null && syncResult['success'] == true) {
//           String? finalImageUrl = syncResult['imageUrl'];

//           if (finalImageUrl == null || finalImageUrl.isEmpty) {
//             final fileName = profileImage.path.split('/').last;
//             String extension = 'jpg';
//             if (fileName.contains('.')) {
//               extension = fileName.split('.').last.toLowerCase();
//             }
//             finalImageUrl = ApiService.buildProfileImageUrl(
//               user.uid,
//               extension: extension,
//             );
//             print(
//               '--------- Built image URL with extension $extension: $finalImageUrl',
//             );
//           }

//           if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
//             await _firestore.collection('users').doc(user.uid).update({
//               'photoUrl': finalImageUrl,
//             });
//             print('--------- Saved image URL to Firestore: $finalImageUrl');
//           }
//         }
//       } else {
//         await _apiService.syncUserToBackend(userModel);
//       }

//       await user.sendEmailVerification();

//       emit(
//         state.copyWith(
//           status: AuthStatus.unauthenticated,
//           firebaseUser: user,
//           userModel: null,
//         ),
//       );

//       _showSnackBar(context, 'Sign Up Success! Please verify your email.');
//       if (context.mounted) {
//         Navigator.pushReplacementNamed(context, '/verification');
//       }
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Sign up failed: $e', context);
//     }
//   }

  

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
//         if (context.mounted) {
//           Navigator.pushReplacementNamed(context, '/main');
//         }
//       } else {
//         emit(
//           state.copyWith(
//             status: AuthStatus.unauthenticated,
//             firebaseUser: user,
//           ),
//         );
//         await user.sendEmailVerification();
//         _showSnackBar(context, 'Please verify your email first.');
//         if (context.mounted) {
//           Navigator.pushReplacementNamed(context, '/verification');
//         }
//       }
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Login failed: $e', context);
//     }
//   }

//   // ==================== دوال التحقق من البريد ====================

//   Future<void> checkEmailVerification(BuildContext context) async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       await user.reload();
//       final refreshedUser = _auth.currentUser;

//       if (refreshedUser != null && refreshedUser.emailVerified) {
//         await _loadUserData(refreshedUser);
//         if (context.mounted) {
//           Navigator.pushReplacementNamed(context, '/main');
//         }
//       }
//     }
//   }

//   Future<void> resendVerificationEmail(BuildContext context) async {
//     try {
//       final user = _auth.currentUser;
//       await user?.sendEmailVerification();
//       _showSnackBar(
//         context,
//         'Verification link sent to your email. Check Your spam.',
//       );
//     } catch (e) {
//       _handleError('Error sending email: $e', context);
//     }
//   }

  

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

//       final updateData = <String, dynamic>{'fullName': fullName, 'bio': bio};

//       if (state.userModel?.role == UserRole.user) {
//         if (university != null) updateData['university'] = university;
//         if (photoUrl != null && photoUrl != state.userModel?.photoUrl) {
//           updateData['photoUrl'] = photoUrl;
//         }
//       } else {
//         if (position != null) updateData['position'] = position;
//         if (department != null) updateData['department'] = department;
//         if (department != null) updateData['university'] = department;
//         if (position != null) updateData['faculty'] = position;
//         if (photoUrl != null && photoUrl != state.userModel?.photoUrl) {
//           updateData['photoUrl'] = photoUrl;
//         }
//       }

//       await _firestore.collection('users').doc(user.uid).update(updateData);

//       final updatedDoc = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       if (updatedDoc.exists) {
//         final updatedUser = UserModel.fromMap(user.uid, updatedDoc.data()!);
//         _isSyncing = true;
//         await _apiService.syncUserToBackend(updatedUser);
//         _isSyncing = false;
//       }

//       await _loadUserData(user);
//       _showSnackBar(context, 'Profile updated successfully!');
//     } catch (e) {
//       _handleError('Failed to update profile: $e', context);
//     }
//   }



//   Future<void> _loadUserData(User user) async {
//     try {
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         final userModel = UserModel.fromMap(user.uid, doc.data()!);

      
//         if (userModel.photoUrl == null || userModel.photoUrl!.isEmpty) {
//           final foundUrl = await ApiService.findImageUrl(user.uid);
//           if (foundUrl != null) {
//             await _firestore.collection('users').doc(user.uid).update({
//               'photoUrl': foundUrl,
//             });
//             final updatedDoc = await _firestore
//                 .collection('users')
//                 .doc(user.uid)
//                 .get();
//             final updatedUser = UserModel.fromMap(user.uid, updatedDoc.data()!);
//             await _syncUserWithDebounce(updatedUser);
//             emit(
//               state.copyWith(
//                 status: AuthStatus.authenticated,
//                 firebaseUser: user,
//                 userModel: updatedUser,
//               ),
//             );
//             return;
//           }
//         }

//         await _syncUserWithDebounce(userModel);
//         emit(
//           state.copyWith(
//             status: AuthStatus.authenticated,
//             firebaseUser: user,
//             userModel: userModel,
//           ),
//         );
//       } else {
//         await user.delete();
//         emit(state.copyWith(status: AuthStatus.unauthenticated));
//       }
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Error loading user data: $e',
//         ),
//       );
//     }
//   }

//   Future<void> logout() async {
//     _syncDebounceTimer?.cancel();
//     _isSyncing = false;
//     await _auth.signOut();
//     _tempSelectedRole = null;
//     emit(state.copyWith(status: AuthStatus.unauthenticated));
//   }

//   Future<void> resetPassword({
//     required String email,
//     required BuildContext context,
//   }) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       _showSnackBar(context, 'Password reset link sent! Check your Spam in Email');
//       if (context.mounted) {
//         Navigator.pop(context);
//       }
//     } on FirebaseAuthException catch (e) {
//       _handleAuthError(e, context);
//     } catch (e) {
//       _handleError('Failed to send reset email: $e', context);
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
//       default:
//         message = e.message ?? 'An error occurred.';
//     }
//     emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
//     _showSnackBar(context, message);
//   }

//   void _handleError(String message, BuildContext context) {
//     emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
//     _showSnackBar(context, message);
//   }

//   void _showSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Future<void> close() {
//     _syncDebounceTimer?.cancel();
//     _authSubscription?.cancel();
//     return super.close();
//   }
// }



import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onboard/models/user_model.dart';
import 'package:onboard/services/api_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();
  StreamSubscription? _authSubscription;

  UserRole? _tempSelectedRole;
  bool _isSyncing = false;
  Timer? _syncDebounceTimer;

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
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              firebaseUser: user,
              userModel: null,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            firebaseUser: null,
            userModel: null,
          ),
        );
      }
    });
  }

  Future<void> _syncUserWithDebounce(UserModel userModel) async {
    _syncDebounceTimer?.cancel();
    if (_isSyncing) return;
    _syncDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!_isSyncing) {
        _isSyncing = true;
        await _apiService.syncUserToBackend(userModel);
        _isSyncing = false;
      }
    });
  }

  Future<String?> _fetchAndUpdateUserImage(String userId) async {
    try {
      final imageUrl = await _apiService.getUserProfileImageUrl(userId);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'photoUrl': imageUrl,
        });
        print('--------- Updated user photoUrl in Firestore: $imageUrl');
        return imageUrl;
      } else {
        final foundUrl = await ApiService.findImageUrl(userId);
        if (foundUrl != null) {
          await _firestore.collection('users').doc(userId).update({
            'photoUrl': foundUrl,
          });
          print('--------- Found and saved image URL: $foundUrl');
          return foundUrl;
        }
      }
    } catch (e) {
      print('--------- Failed to fetch user image: $e');
    }
    return null;
  }

  // ==================== دوال FCM ====================

  Future<void> _saveFcmToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': fcmToken,
        });
        print('✅ FCM Token saved for user: $userId');
      } else {
        print('⚠️ No FCM token available');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  Future<void> signUpUserWithImage({
    required String email,
    required String password,
    required String fullName,
    required String university,
    required String faculty,
    required String track,
    File? profileImage,
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
        photoUrl: null,
        bio: 'Hello, I am $fullName',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      if (profileImage != null) {
        final syncResult = await _apiService.syncUserWithImageToBackend(
          user: userModel,
          imageFile: profileImage,
        );

        if (syncResult != null && syncResult['success'] == true) {
          String? finalImageUrl = syncResult['imageUrl'];

          if (finalImageUrl == null || finalImageUrl.isEmpty) {
            final fileName = profileImage.path.split('/').last;
            String extension = 'jpg';
            if (fileName.contains('.')) {
              extension = fileName.split('.').last.toLowerCase();
            }
            finalImageUrl = ApiService.buildProfileImageUrl(
              user.uid,
              extension: extension,
            );
            print(
              '--------- Built image URL with extension $extension: $finalImageUrl',
            );
          }

          if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
            await _firestore.collection('users').doc(user.uid).update({
              'photoUrl': finalImageUrl,
            });
            print('--------- Saved image URL to Firestore: $finalImageUrl');
          }
        }
      } else {
        await _apiService.syncUserToBackend(userModel);
      }

      // ✅ حفظ FCM Token
      await _saveFcmToken(user.uid);

      await user.sendEmailVerification();

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          firebaseUser: user,
          userModel: null,
        ),
      );

      _showSnackBar(context, 'Sign Up Success! Please verify your email.');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/verification');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Sign up failed: $e', context);
    }
  }

  Future<void> signUpEducatorWithImage({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required String position,
    required String department,
    File? profileImage,
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
        photoUrl: null,
        bio: 'Hello, I am $fullName, $position at $department',
        university: department,
        faculty: position,
        track: 'Management',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      if (profileImage != null) {
        final syncResult = await _apiService.syncUserWithImageToBackend(
          user: userModel,
          imageFile: profileImage,
        );

        if (syncResult != null && syncResult['success'] == true) {
          String? finalImageUrl = syncResult['imageUrl'];

          if (finalImageUrl == null || finalImageUrl.isEmpty) {
            final fileName = profileImage.path.split('/').last;
            String extension = 'jpg';
            if (fileName.contains('.')) {
              extension = fileName.split('.').last.toLowerCase();
            }
            finalImageUrl = ApiService.buildProfileImageUrl(
              user.uid,
              extension: extension,
            );
            print(
              '--------- Built image URL with extension $extension: $finalImageUrl',
            );
          }

          if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
            await _firestore.collection('users').doc(user.uid).update({
              'photoUrl': finalImageUrl,
            });
            print('--------- Saved image URL to Firestore: $finalImageUrl');
          }
        }
      } else {
        await _apiService.syncUserToBackend(userModel);
      }

      // ✅ حفظ FCM Token
      await _saveFcmToken(user.uid);

      await user.sendEmailVerification();

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          firebaseUser: user,
          userModel: null,
        ),
      );

      _showSnackBar(context, 'Sign Up Success! Please verify your email.');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/verification');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Sign up failed: $e', context);
    }
  }

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

        // ✅ حفظ FCM Token
        await _saveFcmToken(user.uid);

        _showSnackBar(context, 'Login Success!');
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            firebaseUser: user,
          ),
        );
        await user.sendEmailVerification();
        _showSnackBar(context, 'Please verify your email first.');
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/verification');
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Login failed: $e', context);
    }
  }

  // ==================== دوال التحقق من البريد ====================

  Future<void> checkEmailVerification(BuildContext context) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        await _loadUserData(refreshedUser);
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    }
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      await user?.sendEmailVerification();
      _showSnackBar(
        context,
        'Verification link sent to your email. Check Your spam.',
      );
    } catch (e) {
      _handleError('Error sending email: $e', context);
    }
  }

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

      final updateData = <String, dynamic>{'fullName': fullName, 'bio': bio};

      if (state.userModel?.role == UserRole.user) {
        if (university != null) updateData['university'] = university;
        if (photoUrl != null && photoUrl != state.userModel?.photoUrl) {
          updateData['photoUrl'] = photoUrl;
        }
      } else {
        if (position != null) updateData['position'] = position;
        if (department != null) updateData['department'] = department;
        if (department != null) updateData['university'] = department;
        if (position != null) updateData['faculty'] = position;
        if (photoUrl != null && photoUrl != state.userModel?.photoUrl) {
          updateData['photoUrl'] = photoUrl;
        }
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      final updatedDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (updatedDoc.exists) {
        final updatedUser = UserModel.fromMap(user.uid, updatedDoc.data()!);
        _isSyncing = true;
        await _apiService.syncUserToBackend(updatedUser);
        _isSyncing = false;
      }

      await _loadUserData(user);
      _showSnackBar(context, 'Profile updated successfully!');
    } catch (e) {
      _handleError('Failed to update profile: $e', context);
    }
  }

  Future<void> _loadUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(user.uid, doc.data()!);

        if (userModel.photoUrl == null || userModel.photoUrl!.isEmpty) {
          final foundUrl = await ApiService.findImageUrl(user.uid);
          if (foundUrl != null) {
            await _firestore.collection('users').doc(user.uid).update({
              'photoUrl': foundUrl,
            });
            final updatedDoc = await _firestore
                .collection('users')
                .doc(user.uid)
                .get();
            final updatedUser = UserModel.fromMap(user.uid, updatedDoc.data()!);
            await _syncUserWithDebounce(updatedUser);
            emit(
              state.copyWith(
                status: AuthStatus.authenticated,
                firebaseUser: user,
                userModel: updatedUser,
              ),
            );
            return;
          }
        }

        await _syncUserWithDebounce(userModel);
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            firebaseUser: user,
            userModel: userModel,
          ),
        );
      } else {
        await user.delete();
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Error loading user data: $e',
        ),
      );
    }
  }

  Future<void> logout() async {
    _syncDebounceTimer?.cancel();
    _isSyncing = false;
    await _auth.signOut();
    _tempSelectedRole = null;
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackBar(context, 'Password reset link sent! Check your Spam in Email');
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, context);
    } catch (e) {
      _handleError('Failed to send reset email: $e', context);
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
      default:
        message = e.message ?? 'An error occurred.';
    }
    emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
    _showSnackBar(context, message);
  }

  void _handleError(String message, BuildContext context) {
    emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
    _showSnackBar(context, message);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Future<void> close() {
    _syncDebounceTimer?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}