import 'package:realm/realm.dart'; // api of the database

part 'note_model.realm.dart';

// define how the data base will save the object

@RealmModel()
class _Note {
  // id
  @PrimaryKey() // PK
  late ObjectId id;

  // properties / fields
  late String title;
  late String content;
  late DateTime createdAt;
  late DateTime updatedAt;
}

extension CopyWithNote on Note {
  Note copyWith({String? title, String? content, DateTime? updatedAt}) {
    return Note(
      id,
      title ?? this.title,
      content ?? this.content,
      createdAt,
      updatedAt ?? this.updatedAt,
    );
  }
}

// class Note {
//   const Note({
//     required this.id,
//     required this.title,
//     required this.content,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   final String id;
//   final String title;
//   final String content;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Note copyWith({
//     String? title,
//     String? content,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return Note(
//       id: id,
//       title: title ?? this.title,
//       content: content ?? this.content,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
