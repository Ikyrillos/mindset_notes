import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  // --------------------------------------------------
  // Mode
  // --------------------------------------------------

  void toggleMode() {
    emit(
      state.copyWith(
        mode: state.isLogin ? AuthMode.register : AuthMode.login,
        status: AuthStatus.initial,
        clearError: true,
      ),
    );
  }

  void setLoginMode() {
    emit(
      state.copyWith(
        mode: AuthMode.login,
        status: AuthStatus.initial,
        clearError: true,
      ),
    );
  }

  void setRegisterMode() {
    emit(
      state.copyWith(
        mode: AuthMode.register,
        status: AuthStatus.initial,
        clearError: true,
      ),
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  // --------------------------------------------------
  // Authentication
  // --------------------------------------------------

  Future<void> submit({
    required String email,
    required String password,
    String? confirmPassword,
  }) async {
    emit(state.copyWith(status: AuthStatus.initial, clearError: true));

    // Validation
    final validationError = _validate(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: validationError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      if (state.isLogin) {
        await _login(email: email, password: password);
      } else {
        await _register(email: email, password: password);
      }

      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final creds = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      log((creds.user?.displayName).toString());

      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    if (email.trim().isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Please enter your email',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      // TODO: Firebase/API forgot password

      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  // --------------------------------------------------
  // Validation
  // --------------------------------------------------

  String? _validate({
    required String email,
    required String password,
    String? confirmPassword,
  }) {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!_isValidEmail(email)) {
      return 'Please enter a valid email';
    }

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (state.isRegister) {
      if (confirmPassword == null || confirmPassword.isEmpty) {
        return 'Please confirm your password';
      }

      if (password != confirmPassword) {
        return 'Passwords do not match';
      }
    }

    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  // --------------------------------------------------
  // API / Firebase
  // --------------------------------------------------

  Future<void> _login({required String email, required String password}) async {
    // login == sign in
    final creds = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = creds.user.toString();

    log(user.toString(), name: 'creds');
  }

  Future<void> _register({
    required String email,
    required String password,
  }) async {
    // register == sign up
    final creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = creds.user.toString();

    log(user.toString(), name: 'creds');
  }
}
