part of 'auth_cubit.dart';

enum AuthMode { login, register }

enum AuthStatus { initial, loading, success, failure }

class AuthState {
  final AuthMode mode;
  final AuthStatus status;
  final bool obscurePassword;
  final String? errorMessage;

  const AuthState({
    this.mode = AuthMode.login,
    this.status = AuthStatus.initial,
    this.obscurePassword = true,
    this.errorMessage,
  });

  bool get isLogin => mode == AuthMode.login;
  bool get isRegister => mode == AuthMode.register;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthMode? mode,
    AuthStatus? status,
    bool? obscurePassword,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
