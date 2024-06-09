import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';


class AllNotes extends StatefulWidget {
  const AllNotes({super.key});

  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {

  List<List<String>> namesOfNotes=[];
  List<List<String>> linkOfNotes=[];
  List<List<String>> notesCourse=[];
  List<List<String>> notesSubject=[];
  List<String> userNames=[];
  List<String> userDPs=[];
  List<String> userUids=[];
  final CollectionReference _notesCollection=FirebaseFirestore.instance
      .collection('notes');


  Future getAllNotes()async {

    QuerySnapshot? snapshot= await _notesCollection.get();
    List<DocumentSnapshot>? allDocs=snapshot.docs;

    //going through all docs and converting into single list of names and notes
    for(DocumentSnapshot snap in allDocs){
      String uid=snap.id;
      userUids.add(uid);

      DocumentSnapshot userSnap=await DatabaseService(uid: uid).getUserSnap();

      userNames.add(userSnap['username']);
      userDPs.add(userSnap['profilePic']);

      namesOfNotes.add(List<String>.from(snap.get('names')));
      linkOfNotes.add(List<String>.from(snap.get('notes')));
      notesCourse.add(List<String>.from(snap.get('course')));
      notesSubject.add(List<String>.from(snap.get('subject')));
    }
  }


  @override
  Widget build(BuildContext context){

    // Clear the lists to prevent duplicates
    namesOfNotes.clear();
    linkOfNotes.clear();
    notesSubject.clear();
    notesCourse.clear();
    userNames.clear();
    userDPs.clear();

    return FutureBuilder(
      //getting the snapshot from DB only once
      future: getAllNotes(),
      builder: (context, AsyncSnapshot<void> snap){
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        return ListView.builder(
            itemCount: namesOfNotes.length,
            itemBuilder: (context, index){
              String pdfLink="";
              String pdfName="";
              String course="";
              String subject="";
              String userName=userNames[index];
              String userDP=userDPs[index];
              String userUid=userUids[index];
              List<Widget> notesTiles = [];

              List<String> pdfNamesList=namesOfNotes[index];
              List<String> pdfLinksList=linkOfNotes[index];
              List<String> courseList=notesCourse[index];
              List<String> subjectList=notesSubject[index];

              for(var i=0;i<pdfNamesList.length;i++){
                pdfName=pdfNamesList[i];
                pdfLink=pdfLinksList[i];
                course=courseList[i];
                subject=subjectList[i];
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
        );
      }
      );
  }
}
