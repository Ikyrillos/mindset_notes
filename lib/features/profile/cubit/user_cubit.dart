import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindset_notes/features/profile/cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  final FirebaseAuth _auth;

  UserCubit({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      super(
        UserState(user: auth?.currentUser ?? FirebaseAuth.instance.currentUser),
      );

  // ----------------------------
  // Update Profile
  // ----------------------------

  Future<void> updateProfile({
    required String displayName,
    required String email,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'No user is currently signed in.',
        ),
      );
      return;
    }

    if (displayName.trim().isEmpty) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'Name cannot be empty.',
        ),
      );
      return;
    }

    if (email.trim().isEmpty) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'Email cannot be empty.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: UserStatus.loading));

    try {
      // Update display name
      await user.updateDisplayName(displayName.trim());

      // Update email if it changed
      if (email.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }

      await user.reload();

      final updatedUser = _auth.currentUser;

      emit(state.copyWith(status: UserStatus.success, user: updatedUser));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: _firebaseError(e),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: UserStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  // ----------------------------
  // Update Password
  // ----------------------------

  Future<void> updatePassword(String password) async {
    final user = _auth.currentUser;

    if (user == null) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'No user is currently signed in.',
        ),
      );
      return;
    }

    if (password.length < 6) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: 'Password must be at least 6 characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: UserStatus.loading));

    try {
      await user.updatePassword(password);

      emit(state.copyWith(status: UserStatus.success, user: user));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: _firebaseError(e),
        ),
      );
    }
  }

  // ----------------------------
  // Logout
  // ----------------------------

  Future<void> logout() async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      await _auth.signOut();

      emit(state.copyWith(status: UserStatus.success, user: null));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: _firebaseError(e),
        ),
      );
    }
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Please sign in again before changing this information.';

      case 'email-already-in-use':
        return 'This email is already being used.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}
