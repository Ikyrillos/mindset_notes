// // realm pr any databse

// // cant have void return types all time
// // it returns Data
// import 'dart:developer';

// import 'package:mindset_notes/core/config/realm_config.dart';
// import 'package:mindset_notes/features/notes/data/models/note_model.dart';
// import 'package:mindset_notes/features/notes/data/repository/notes_repo_interface.dart';
// import 'package:realm/realm.dart';

// // manage data
// class OfflineNotesRepository implements NotesRepository {
//   // get all
//   @override
//   Future<List<Note>> getAll() async {
//     return realm.all<Note>().toList();
//   }

//   // get by id
//   @override
//   Note? getById(Object id) {
//     return realm.find(id);
//   }

//   // add
//   @override
//   Future<void> add({required String title, required String content}) async {
//     final now = DateTime.now();

//     final note = Note(ObjectId(), title, content, now, now);

//     // database collection -> object
//     // add , update , delete
//     realm.write(() {
//       realm.add(note);
//     });
//   }

//   // update
//   @override
//   void update(Note note) {
//     final newNote = note.copyWith(updatedAt: DateTime.now());

//     // databse
//     realm.write(() {
//       // add , already exist = update
//       realm.add(newNote, update: true);
//     });
//   }

//   // delete
//   @override
//   void delete(Object id) {
//     final note = getById(id);

//     if (note == null) {
//       log('item not found');
//       return;
//     }
//     // database
//     realm.write(() {
//       realm.delete(note);
//     });
//   }
// }
