

import 'package:cloud_firestore/cloud_firestore.dart';

class NotesModel1 {

  String notesLink;
  String notesName;
  String notesCourse;
  String notesSubject;
  String notesDescription;
  int notesLikes;
  String uid;
  DateTime uploadedAt;

  NotesModel1({required this.uid, required this.notesLink, required this.notesName, required this.notesCourse, required this.notesSubject, required this.notesDescription, required this.notesLikes, required this.uploadedAt});
}