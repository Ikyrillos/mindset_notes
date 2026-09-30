import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindset_notes/features/notes/data/models/online_note.dart';
import 'package:mindset_notes/features/notes/data/repository/notes_repo_interface.dart';

const noteCollection = 'Notes';

class OnlineNotesRepository implements NotesRepository {
  final db = FirebaseFirestore.instance;
  @override
  Future<void> add({required String title, required String content}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (isUserSignedIn()) {
      final doc = await db.collection(noteCollection).add({
        'title': title,
        'content': content,
        'userId': user!.uid,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      final contentAdded = await doc.get();
      log(contentAdded.data().toString());
    } else {
      log('unable to add note');
    }
  }

  @override
  Future<void> delete(String id) async {
    final doc = await getById(id);
    await doc?.delete();
  }

  @override
  Future<List<FirebaseNote>> getAll() async {
    final user = FirebaseAuth.instance.currentUser;
    log('user?.uid ${user?.uid} ');
    final res = (await db.collection(noteCollection).get()).docs
        .where((element) => element['userId'] == user?.uid)
        .map((e) {
          final data = {...e.data(), 'id': e.id};
          return data;
        })
        .toList();

    final firebaseNote = res.map((e) => FirebaseNote.fromJson(e)).toList();
    log(firebaseNote.length.toString());

    return firebaseNote;
  }

  @override
  Future<DocumentReference<Map<String, dynamic>>>? getById(String id) async {
    return FirebaseFirestore.instance.collection(noteCollection).doc(id);
  }

  @override
  Future<void> update(FirebaseNote note) async {
    await FirebaseFirestore.instance
        .collection(noteCollection)
        .doc(note.id)
        .update(note.toJson());
  }

  bool isUserSignedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return true;
    }

    return false;
  }
}
