import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatelessWidget {
  HomeBody({super.key});

  List<List<String>> namesOfNotes=[];
  List<List<String>> linkOfNotes=[];
  List<List<String>> notesCourse=[];
  List<List<String>> notesSubject=[];
  List<String> userNames=[];
  List<String> userDPs=[];

  List<String> followingList=[];

  Future followingNotes()async {

    for(String uid in followingList){
      //
      DocumentSnapshot userSnap=await DatabaseService(uid: uid).getUserSnap();
      DocumentSnapshot notesSnap=await DatabaseService(uid: uid).getNotesSnap();

      userNames.add(userSnap['username']);
      userDPs.add(userSnap['profilePic']);

      namesOfNotes.add(List<String>.from(notesSnap.get('names')));
      linkOfNotes.add(List<String>.from(notesSnap.get('notes')));
      notesCourse.add(List<String>.from(notesSnap.get('course')));
      notesSubject.add(List<String>.from(notesSnap.get('subject')));
    }

  }

  @override
  Widget build(BuildContext context) {

    final userUid=Provider.of<UserUid?>(context);

    //listening to userData
    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService(uid: userUid?.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot? userSnap = snapshot.data;
          if(userSnap!= null){
            followingList=List<String>.from(userSnap['following']);
          }
          // Clear the lists to prevent duplicates
          namesOfNotes.clear();
          linkOfNotes.clear();
          notesSubject.clear();
          notesCourse.clear();
          userNames.clear();
          userDPs.clear();

          return FutureBuilder(
              //getting the following list user data
              future: followingNotes(),
              builder: (context, AsyncSnapshot<void> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                return namesOfNotes.isNotEmpty? ListView.builder(
                    itemCount: namesOfNotes.length,
                    itemBuilder: (context, index) {
                      String pdfLink = "";
                      String pdfName = "";
                      String course = "";
                      String subject = "";
                      String userName = userNames[index];
                      String userDP = userDPs[index];
                      String userUid = followingList[index];
                      List<Widget> notesTiles = [];
                      List<String> pdfNamesList = namesOfNotes[index];
                      List<String> pdfLinksList = linkOfNotes[index];
                      List<String> courseList = notesCourse[index];
                      List<String> subjectList = notesSubject[index];

                      for (var i = 0; i < pdfNamesList.length; i++) {
                        pdfName = pdfNamesList[i];
                        pdfLink = pdfLinksList[i];
                        course = courseList[i];
                        subject = subjectList[i];
                        //creating List of widgets
                        notesTiles.add(NotesTile(
                          pdfLink: pdfLink,
                          name: pdfName,
                          userDP: userDP,
                          userName: userName,
                          subject: subject,
                          course: course,
                          userUid: userUid,
                        )
                        );
                      }
                      //Adding that list of widget in column to show
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: notesTiles,
                      );
                    }
                ):Center(
                  child: Text('You are not following anyone!!'),
                );
              }
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}
