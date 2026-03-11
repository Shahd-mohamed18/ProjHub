part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? firebaseUser;
  final UserModel? userModel;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.firebaseUser,
    this.userModel,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? firebaseUser,
    UserModel? userModel,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userModel: userModel ?? this.userModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}