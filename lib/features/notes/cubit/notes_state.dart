import 'package:mindset_notes/features/notes/data/models/online_note.dart';

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FirebaseNote> notes;
  final bool isLoading;
  final String? errorMessage;

  NotesState copyWith({
    List<FirebaseNote>? notes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
