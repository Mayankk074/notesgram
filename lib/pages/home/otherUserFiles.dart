import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';

import '../../models/userUid.dart';

class OtherUserFiles extends StatelessWidget {
  OtherUserFiles({super.key});

  Map data={};
  DocumentSnapshot? userSnap;
  DocumentSnapshot? notesSnap;
  DocumentSnapshot? currUserSnap;

  @override
  Widget build(BuildContext context) {



    data=ModalRoute.of(context)!.settings.arguments as Map;
    currUserSnap=data['currentUserSnap'];
    HashSet<String> liked=HashSet<String>.from(currUserSnap?['liked']);

    userSnap=data['userSnap'];
    notesSnap=data['notesSnap'];

    List<String> notesList=List<String>.from(notesSnap?['notes']);
    List<String> notesName=List<String>.from(notesSnap?['names']);
    List<String> notesCourse=List<String>.from(notesSnap?['course']);
    List<String> notesSubject=List<String>.from(notesSnap?['subject']);
    List<String> notesDescription=List<String>.from(notesSnap?['description']);
    List<int> notesLikes=List<int>.from(notesSnap?['likes']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Files'),
      ),
      body: ListView.builder(
          itemCount: notesList.length,
          itemBuilder: (context, index){
            bool likedFlag=liked.contains(notesList[index]);
            return NotesTile(
              pdfLink: notesList[index],
              name: notesName[index],
              userName: userSnap?['username'],
              userDP: userSnap?['profilePic'],
              course: notesCourse[index],
              subject: notesSubject[index],
              userUid: userSnap?.id,
              likedFlag: likedFlag,
              description: notesDescription[index],
              likesCount: notesLikes[index],
            );
          },
      ),
    );
  }
}

