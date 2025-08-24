
class NotesModel {

  String notesLink;
  String notesName;
  String notesCourse;
  String notesSubject;
  String notesDescription;
  int notesLikes;
  String uid;
  DateTime uploadedAt;

  NotesModel({required this.uid, required this.notesLink, required this.notesName, required this.notesCourse, required this.notesSubject, required this.notesDescription, required this.notesLikes, required this.uploadedAt});
}