import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindset_notes/features/profile/cubit/user_cubit.dart';
import 'package:mindset_notes/features/profile/cubit/user_state.dart';

import '../../../../core/routes/route_constants.dart';
import '../../cubit/notes_cubit.dart';
import '../../cubit/notes_state.dart';
import '../widgets/empty_notes.dart';
import '../widgets/note_card.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state.user != null) {
              return Text('Hello,  ${state.user!.displayName}');
            }
            return const Text('My Notes');
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.noteEditor);
            },
            icon: const Icon(Icons.add),
          ),

          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.userScreen);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(child: Text(state.errorMessage!));
          }

          if (state.notes.isEmpty) {
            return const EmptyNotes();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = state.notes[index];

              return NoteCard(
                note: note,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteConstants.noteEditor,
                    arguments: note,
                  );
                },
                onDelete: () {
                  context.read<NotesCubit>().deleteNote(note.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstants.noteEditor);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
