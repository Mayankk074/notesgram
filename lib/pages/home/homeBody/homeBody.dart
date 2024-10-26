import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/note.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatefulWidget {
  HomeBody({super.key, this.user});

  UserUid? user;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<Note> allNotes=[];

  List<String> followingList=[];

  Future followingNotes()async {
    DocumentSnapshot snap=await DatabaseService(uid: widget.user?.uid).getUserSnap();

    followingList=List<String>.from(snap['following']);

    for(String uid in followingList){
      DocumentSnapshot userSnap=await DatabaseService(uid: uid).getUserSnap();
      DocumentSnapshot notesSnap=await DatabaseService(uid: uid).getNotesSnap();

      List<String> namesList=List<String>.from(notesSnap.get('names'));
      List<String> notesList=List<String>.from(notesSnap.get('notes'));
      List<String> courseList=List<String>.from(notesSnap.get('course'));
      List<String> subjectList=List<String>.from(notesSnap.get('subject'));
      List<String> listDescription=List<String>.from(notesSnap.get('description'));
      List<int> listLikes=List<int>.from(notesSnap.get('likes'));

      for(int i=0;i<namesList.length;i++){
        //Creating Note objects from lists notes from snap
        allNotes.add(Note(
          name: namesList[i],
          link: notesList[i],
          course: courseList[i],
          subject: subjectList[i],
          userName:userSnap['username'],
          userDP: userSnap['profilePic'],
          userUid: uid,
          description: listDescription[i],
          likesCount: listLikes[i],
        ));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    followingNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDoc=Provider.of<DocumentSnapshot?>(context);
    HashSet<String> liked=HashSet<String>();
    if(userDoc != null){
      liked=HashSet<String>.from(userDoc['liked']);
    }

    return allNotes.isNotEmpty? ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (context, index) {
          Note note=allNotes[index];
          bool likedFlag=liked.contains(note.link);
          return NotesTile(
            pdfLink: note.link,
            name: note.name,
            userDP: note.userDP,
            userName: note.userName,
            subject: note.subject,
            course: note.course,
            userUid: note.userUid,
            description: note.description,
            likedFlag: likedFlag,
            likesCount: note.likesCount,
            );
          }
    ):const Center(
      child: Text('You are not following anyone!!'),
    );
  }
}
