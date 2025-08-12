import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/notesModel1.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';

import '../../../models/note.dart';
import '../../../models/userUid.dart';
import '../notesTile.dart';

class SavedNotes extends StatefulWidget {
  const SavedNotes({super.key});

  @override
  State<SavedNotes> createState() => _SavedNotesState();
}

class _SavedNotesState extends State<SavedNotes> {
  List<Note> savedNotes=[];
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    UserUid userUid=Provider.of<UserUid>(context);
    getSavedNotes(userUid.uid);
  }
  void getSavedNotes(String? userUid) async {
    savedNotes=await DatabaseService(uid: userUid).getSavedNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //getting the userData from the arguments
    Map data=ModalRoute.of(context)?.settings.arguments as Map;
    DocumentSnapshot userDoc=data['userDoc'];
    HashSet<String> liked=HashSet<String>.from(userDoc['liked']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Notes'),
      ),
      body: savedNotes.isNotEmpty ? Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: savedNotes.length,
          itemBuilder: (context, index){
            bool likedFlag=liked.contains(savedNotes[index].link);
            //creating NotesTile
            return NotesTile(
              pdfLink: savedNotes[index].link,
              name: savedNotes[index].name,
              userName: savedNotes[index].userName,
              userDP: savedNotes[index].userDP,
              course: savedNotes[index].course,
              subject: savedNotes[index].subject,
              userUid: savedNotes[index].userUid,
              description: savedNotes[index].description,
              likedFlag: likedFlag,
              likesCount: savedNotes[index].likesCount,
              id: savedNotes[index].noteId,
              currUserDoc: userDoc,
            );
          }),
      ) : const Center(
        child: Text('No Saved Notes'),
      ),
    );
  }
}
