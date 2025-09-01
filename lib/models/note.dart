import 'package:hive/hive.dart';

part 'note.g.dart'; // run build_runner after this

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String name;
  @HiveField(1)
  String link;
  @HiveField(2)
  String? path;
  @HiveField(3)
  String course;
  @HiveField(4)
  String subject;
  @HiveField(5)
  String userName;
  @HiveField(6)
  String userDP;
  @HiveField(7)
  String userUid;
  @HiveField(8)
  String description;
  @HiveField(9)
  int likesCount;
  @HiveField(10)
  DateTime uploadedAt;
  @HiveField(11)
  String noteId;


  Note({
    required this.name,
    required this.link,
    this.path,
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
