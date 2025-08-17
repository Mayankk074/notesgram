
import 'package:cloud_firestore/cloud_firestore.dart';

class Note{

  String? name;
  String? link;
  String? course;
  String? subject;
  String? userUid;
  String? userName;
  String? userDP;
  String? description;
  int? likesCount;
  String? noteId;
  DateTime? uploadedAt;

  Note({this.subject,this.noteId, this.userUid,this.userDP,this.name,this.course,this.userName,this.link, this.description, this.likesCount, this.uploadedAt});
}