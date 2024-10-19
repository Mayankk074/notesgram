import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';

class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {

    // final userDoc=Provider.of<DocumentSnapshot?>(context);
    final notesDocument=Provider.of<NotesModel?>(context);
    final userDoc=Provider.of<DocumentSnapshot?>(context);


    List<String>? notesList=notesDocument?.notesLink;
    List<String>? notesNames=notesDocument?.notesName;
    List<String>? notesCourse=notesDocument?.notesCourse;
    List<String>? notesSubject=notesDocument?.notesSubject;
    List<String>? notesDescription=notesDocument?.notesDescription;

    return userDoc==null ? const LoadingShared():
        notesList !=null ?
      ListView.builder(
      itemCount: notesList.length,
      itemBuilder: (context, index){
        return NotesTile(
          pdfLink: notesList[index],
          name: notesNames?[index],
          userName: userDoc['username'],
          userDP: userDoc['profilePic'],
          course: notesCourse?[index],
          subject: notesSubject?[index],
          userUid: userDoc.id,
          description: notesDescription?[index],
        );
      }
    ): const Center(
          child: Text('No file is uploaded!!'),
        );
  }
}
