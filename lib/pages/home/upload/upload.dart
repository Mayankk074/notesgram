import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';

import '../../../models/notesModel1.dart';

class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {

    // final userDoc=Provider.of<DocumentSnapshot?>(context);
    final notesList=Provider.of<List<NotesModel1?>>(context);
    final userDoc=Provider.of<DocumentSnapshot?>(context);

    HashSet<String> liked=HashSet<String>.from(userDoc?['liked']);

    //To show message if user deletes all the pdfs.
    if(notesList.isEmpty){
      return const Center(
        child: Text('No file is uploaded!!'),
      );
    }

    return userDoc==null ? const LoadingShared():
      ListView.builder(
      itemCount: notesList.length,
      itemBuilder: (context, index){
        bool likedFlag=liked.contains(notesList[index]?.notesLink);
        return NotesTile(
          pdfLink: notesList[index]!.notesLink,
          name: notesList[index]?.notesName,
          userName: userDoc['username'],
          userDP: userDoc['profilePic'],
          course: notesList[index]!.notesCourse,
          subject: notesList[index]!.notesSubject,
          userUid: userDoc.id,
          description: notesList[index]!.notesDescription,
          likedFlag: likedFlag,
          likesCount: notesList[index]!.notesLikes,
          uploadedAt: notesList[index]!.uploadedAt,
          id: notesList[index]!.uid,
        );
      }
    );
  }
}
