import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindset_notes/features/notes/cubit/notes_cubit.dart';
import 'package:mindset_notes/features/notes/data/models/online_note.dart';
import 'package:mindset_notes/features/notes/data/repository/notes_repo_interface.dart';

class FakeRepo implements NotesRepository {
  final fetches = <Completer<List<FirebaseNote>>>[];

  @override
  Future<List<FirebaseNote>> getAll() {
    final c = Completer<List<FirebaseNote>>();
    fetches.add(c);
    return c.future;
  }

  @override
  Future<void> add({required String title, required String content}) async {}
  @override
  Future<void> update(FirebaseNote note) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<DocumentReference<Map<String, dynamic>>>? getById(String id) => null;
}

FirebaseNote note(String id) => FirebaseNote(
  id: id,
  title: id,
  content: id,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  test('account switch clears old notes and discards in-flight stale fetch', () async {
    final repo = FakeRepo();
    final auth = StreamController<String?>();
    final cubit = NotesCubit(repo, authUid: auth.stream);

    auth.add('A');
    await pumpEventQueue();
    repo.fetches[0].complete([note('a-note')]);
    await pumpEventQueue();
    expect(cubit.state.notes.map((n) => n.id), ['a-note']);

    // Start a fetch as A, then switch to B before it returns.
    cubit.getAllNotes();
    auth.add('B');
    await pumpEventQueue();
    expect(cubit.state.notes, isEmpty);

    repo.fetches[1].complete([note('stale-a-note')]); // A's late result
    repo.fetches[2].complete([note('b-note')]);
    await pumpEventQueue();
    expect(cubit.state.notes.map((n) => n.id), ['b-note']);
    expect(cubit.state.isLoading, isFalse);

    auth.add(null); // logout
    await pumpEventQueue();
    expect(cubit.state.notes, isEmpty);
    await cubit.close();
  });
}
