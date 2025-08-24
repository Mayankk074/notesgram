import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';

import '../../models/notesModel.dart';

class OtherUserFiles extends StatelessWidget {
  OtherUserFiles({super.key});

  Map data={};
  DocumentSnapshot? userSnap;
  List<NotesModel?> notesSnap=[];
  DocumentSnapshot? currUserSnap;

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

        //Stream for NotesSnap of otherUser for notes
        return StreamBuilder<List<NotesModel?>>(
            stream: DatabaseService(uid:userSnap?.id).notesData,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                notesSnap=snapshot.data!;
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Uploaded Files'),
                  ),
                  body: ListView.builder(
                    itemCount: notesSnap.length,
                    itemBuilder: (context, index){
                      bool likedFlag=liked.contains(notesSnap[index]?.notesLink);
                      return NotesTile(
                        pdfLink: notesSnap[index]?.notesLink,
                        name: notesSnap[index]?.notesName,
                        userName: userSnap?['username'],
                        userDP: userSnap?['profilePic'],
                        course: notesSnap[index]?.notesCourse,
                        subject: notesSnap[index]?.notesSubject,
                        userUid: userSnap?.id,
                        likedFlag: likedFlag,
                        description: notesSnap[index]?.notesDescription,
                        likesCount: notesSnap[index]?.notesLikes,
                        currUserDoc: currUserSnap,
                        uploadedAt: notesSnap[index]?.uploadedAt,
                        //Note document id
                        id: notesSnap[index]!.uid,
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

