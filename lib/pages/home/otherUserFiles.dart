import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';

class OtherUserFiles extends StatelessWidget {
  OtherUserFiles({super.key});

  Map data={};
  DocumentSnapshot? userSnap;
  NotesModel? notesSnap;
  DocumentSnapshot? currUserSnap;

  List<String> notesList=[];
  List<String> notesName=[];
  List<String> notesCourse=[];
  List<String> notesSubject=[];
  List<String> notesDescription=[];
  List<int> notesLikes=[];

  //for assigning the notes Lists
  void getNotesData(){
    notesList=notesSnap!.notesLink!;
    notesName=notesSnap!.notesName!;
    notesCourse=notesSnap!.notesCourse!;
    notesSubject=notesSnap!.notesSubject!;
    notesDescription=notesSnap!.notesDescription!;
    notesLikes=notesSnap!.notesLikes!;
  }

  @override
  Widget build(BuildContext context) {
    final userUid=Provider.of<UserUid>(context);
    data=ModalRoute.of(context)!.settings.arguments as Map;
    userSnap=data['userSnap'];

    //Stream for currUserSnap so it would change the likedFlag
    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService(uid:userUid.uid).userData,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingShared();
        }
        currUserSnap=userSnapshot.data;
        HashSet<String> liked=HashSet<String>.from(currUserSnap?['liked']);

        //Stream for NotesSnap for otherUser for notes
        return StreamBuilder<NotesModel?>(
            stream: DatabaseService(uid:userSnap?.id).notesData,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                notesSnap=snapshot.data;
                getNotesData();
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
                        currUserDoc: currUserSnap,
                      );
                    },
                  ),
                );
              }
              else{
                return const LoadingShared();
              }

            }
        );
      },

    );
  }
}

