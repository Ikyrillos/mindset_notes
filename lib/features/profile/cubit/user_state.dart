import 'package:firebase_auth/firebase_auth.dart';

enum UserStatus { initial, loading, success, failure }

class UserState {
  final UserStatus status;
  final User? user;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isLoading => status == UserStatus.loading;

  UserState copyWith({UserStatus? status, User? user, String? errorMessage}) {
    return UserState(
      status: status ?? this.status,
      user: user,
      errorMessage: errorMessage,
    );
  }
}
