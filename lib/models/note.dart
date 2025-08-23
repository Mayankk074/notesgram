import 'package:hive/hive.dart';

part 'note.g.dart'; // run build_runner after this

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String name;
  @HiveField(1)
  String link;
  @HiveField(2)
  String course;
  @HiveField(3)
  String subject;
  @HiveField(4)
  String userName;
  @HiveField(5)
  String userDP;
  @HiveField(6)
  String userUid;
  @HiveField(7)
  String description;
  @HiveField(8)
  int likesCount;
  @HiveField(9)
  DateTime uploadedAt;
  @HiveField(10)
  String noteId;

  Note({
    required this.name,
    required this.link,
    required this.course,
    required this.subject,
    required this.userName,
    required this.userDP,
    required this.userUid,
    required this.description,
    required this.likesCount,
    required this.uploadedAt,
    required this.noteId,
  });
}
