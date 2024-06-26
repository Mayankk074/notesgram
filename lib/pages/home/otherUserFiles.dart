import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/notesTile.dart';

class OtherUserFiles extends StatelessWidget {
  OtherUserFiles({super.key});

  Map data={};
  DocumentSnapshot? userSnap;
  DocumentSnapshot? notesSnap;

  @override
  Widget build(BuildContext context) {

    data=ModalRoute.of(context)!.settings.arguments as Map;

    userSnap=data['userSnap'];
    notesSnap=data['notesSnap'];

    List<String> notesList=List<String>.from(notesSnap?['notes']);
    List<String> notesName=List<String>.from(notesSnap?['names']);
    List<String> notesCourse=List<String>.from(notesSnap?['course']);
    List<String> notesSubject=List<String>.from(notesSnap?['subject']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Files'),
      ),
      body: ListView.builder(
          itemCount: notesList.length,
          itemBuilder: (context, index){
            return NotesTile(
              pdfLink: notesList[index],
              name: notesName[index],
              userName: userSnap?['username'],
              userDP: userSnap?['profilePic'],
              course: notesCourse[index],
              subject: notesSubject[index],
              userUid: userSnap?.id,
            );
          },
      ),
    );
  }
}

