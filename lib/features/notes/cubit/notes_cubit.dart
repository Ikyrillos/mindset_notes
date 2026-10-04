import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindset_notes/features/notes/data/models/online_note.dart';
import 'package:mindset_notes/features/notes/data/repository/notes_repo_interface.dart';

import 'notes_state.dart';

// presentation - UI
// data layer - models + repository
// cubit -> state

// SOC sepration of concern

class NotesCubit extends Cubit<NotesState> {
  /// [authUid] emits the signed-in user's uid (or null when signed out).
  /// Notes are cleared and reloaded on every change so one account's notes
  /// never linger after switching to another.
  NotesCubit(this._notesRepo, {Stream<String?>? authUid})
    : super(const NotesState()) {
    _authSub = authUid?.distinct().listen((uid) {
      clear();
      if (uid != null) getAllNotes();
    });
  }

  final NotesRepository _notesRepo;
  StreamSubscription<String?>? _authSub;

  // Incremented on every fetch and on clear(); a fetch whose id is no longer
  // current is stale (older fetch, or the account changed) and is discarded.
  int _requestId = 0;

  Future<void> getAllNotes() async {
    final id = ++_requestId;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final notes = await _notesRepo.getAll();
      if (id != _requestId || isClosed) return;
      emit(state.copyWith(notes: notes.toList(), isLoading: false));
    } on Exception catch (e) {
      if (id != _requestId || isClosed) return;
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> addNote({required String title, required String content}) async {
    await _notesRepo.add(title: title, content: content);
    await getAllNotes();
  }

  Future<void> updateNote(FirebaseNote note) async {
    await _notesRepo.update(note);
    await getAllNotes();
  }

  Future<void> deleteNote(String id) async {
    await _notesRepo.delete(id);
    await getAllNotes();
  }

  void clear() {
    _requestId++;
    emit(const NotesState());
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
