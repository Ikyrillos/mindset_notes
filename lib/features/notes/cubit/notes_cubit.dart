import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindset_notes/features/notes/data/models/online_note.dart';
import 'package:mindset_notes/features/notes/data/repository/notes_repo_interface.dart';

import 'notes_state.dart';

// presentation - UI
// data layer - models + repository
// cubit -> state

// SOC sepration of concern

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._notesRepo) : super(const NotesState());

  final NotesRepository _notesRepo;

  void getAllNotes() async {
    emit(state.copyWith(isLoading: true));
    try {
      final notes = await _notesRepo.getAll();
      emit(state.copyWith(notes: notes.toList(), isLoading: false));
    } on Exception catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void addNote({required String title, required String content}) {
    _notesRepo.add(title: title, content: content);
    getAllNotes();
  }

  void updateNote(FirebaseNote note) {
    _notesRepo.update(note);
    getAllNotes();
  }

  void deleteNote(String id) {
    _notesRepo.delete(id);
    getAllNotes();
  }

  void clear() {
    emit(NotesState());
  }
}
