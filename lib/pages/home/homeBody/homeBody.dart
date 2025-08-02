import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/note.dart';
import 'package:notesgram/models/notesModel1.dart';
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

    allNotes.clear(); // clear old notes
    followingList.clear(); // clear old following

    DocumentSnapshot snap=await DatabaseService(uid: widget.user?.uid).getUserSnap();

    followingList=List<String>.from(snap['following']);

    for(String uid in followingList){
      //userDetails of followed user.
      DocumentSnapshot userSnap=await DatabaseService(uid: uid).getUserSnap();
      //getting all Notes of user from following list.
      List<NotesModel1?> notesList =await DatabaseService(uid: uid).notesDataFromCollection();

      for(int i=0;i<notesList.length;i++){
        //Creating Note objects from lists notes from snap
        allNotes.add(Note(
          name: notesList[i]?.notesName,
          link: notesList[i]?.notesLink,
          course: notesList[i]?.notesCourse,
          subject: notesList[i]?.notesSubject,
          userName:userSnap['username'],
          userDP: userSnap['profilePic'],
          userUid: uid,
          description: notesList[i]?.notesDescription,
          likesCount: notesList[i]?.notesLikes,
          noteId: notesList[i]?.uid
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
            id: note.noteId,
            refreshCallback: followingNotes, //sending call back function to refresh the screen after following/unfollowing
            );
          }
    ):const Center(
      child: Text('You are not following anyone!!'),
    );
  }
}
