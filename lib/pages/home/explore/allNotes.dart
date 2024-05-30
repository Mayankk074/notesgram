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
  List<String> userNames=[];
  List<String> userDPs=[];
  final CollectionReference _notesCollection=FirebaseFirestore.instance
      .collection('notes');


  Future getAllNotes()async {

    QuerySnapshot? snapshot= await _notesCollection.get();

    print("get all notes");
    print(namesOfNotes);
    List<DocumentSnapshot>? allDocs=snapshot.docs;
    print(namesOfNotes);

    //going through all docs and converting into single list of names and notes
    for(DocumentSnapshot snap in allDocs){
      String uid=snap.id;

      DocumentSnapshot userSnap=await DatabaseService(uid: uid).getUserSnap();

      userNames.add(userSnap['username']);
      userDPs.add(userSnap['profilePic']);

      namesOfNotes.add(List<String>.from(snap.get('names')));
      linkOfNotes.add(List<String>.from(snap.get('notes')));
    }
    print(namesOfNotes);
  }


  @override
  Widget build(BuildContext context){

    // Clear the lists to prevent duplicates
    namesOfNotes.clear();
    linkOfNotes.clear();
    userNames.clear();
    userDPs.clear();

    return FutureBuilder(
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
              print(namesOfNotes);

              String pdfLink="";
              String pdfName="";
              String userName=userNames[index];
              String userDP=userDPs[index];
              List<Widget> notesTiles = [];

              List<String> pdfNamesList=namesOfNotes[index];
              List<String> pdfLinksList=linkOfNotes[index];

              for(var i=0;i<pdfNamesList.length;i++){
                pdfName=pdfNamesList[i];
                pdfLink=pdfLinksList[i];
                //creating List of widgets
                notesTiles.add(NotesTile(pdfLink: pdfLink, name: pdfName, userDP: userDP,userName: userName,));
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
