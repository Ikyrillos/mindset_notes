import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindset_notes/features/notes/data/models/online_note.dart';

abstract class NotesRepository {
  Future<List<FirebaseNote>> getAll();

  Future<void> add({required String title, required String content});

  Future<void> update(FirebaseNote note);

  Future<void> delete(String id);

  Future<DocumentReference<Map<String, dynamic>>>? getById(String id);
}
