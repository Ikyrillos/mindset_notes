import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindset_notes/core/routes/route_constants.dart';
import 'package:mindset_notes/features/profile/cubit/user_cubit.dart';
import 'package:mindset_notes/features/profile/cubit/user_state.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserView();
  }
}

class _UserView extends StatefulWidget {
  const _UserView();

  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    nameController = TextEditingController(text: user?.displayName ?? '');

    emailController = TextEditingController(text: user?.email ?? '');

    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void saveProfile() {
    context.read<UserCubit>().updateProfile(
      displayName: nameController.text,
      email: emailController.text,
    );
  }

  void changePassword() {
    context.read<UserCubit>().updatePassword(passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state.status == UserStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Changes saved successfully')),
          );
        }

        if (state.status == UserStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }

        // If logout was successful, go back.
        if (state.status == UserStatus.success && state.user == null) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundImage: state.user?.photoURL != null
                      ? NetworkImage(state.user!.photoURL!)
                      : null,
                  child: state.user?.photoURL == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),

                const SizedBox(height: 32),

                // Name
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // Save
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: state.isLoading ? null : saveProfile,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),

                const SizedBox(height: 40),

                const Divider(),

                const SizedBox(height: 24),

                const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: state.isLoading ? null : changePassword,
                  child: const Text('Change Password'),
                ),

                const SizedBox(height: 40),

                const Divider(),

                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context.read<UserCubit>().logout();
                            Navigator.pushReplacementNamed(
                              context,
                              RouteConstants.auth,
                            );
                          },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
