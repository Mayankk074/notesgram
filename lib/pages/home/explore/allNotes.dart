import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/note.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:provider/provider.dart';

import '../../../models/userUid.dart';


class AllNotes extends StatefulWidget {
  const AllNotes({super.key, required this.currUserUid});

  final UserUid currUserUid;
  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {
  //Lists of Note object to be displayed
  List<Note> allNotes=[];
  List<Note> filteredNotes=[];
  int loadLength=11;

  final CollectionReference _notesCollection=FirebaseFirestore.instance
      .collection('notes');

  //Text controller for search field
  final TextEditingController _searchController=TextEditingController();

  Future getAllNotes()async {
    //getting all documents from the collection of 'notes'
    QuerySnapshot? snapshot = await _notesCollection.get();
    List<DocumentSnapshot>? allDocs = snapshot.docs;

    //going through all docs and converting into single list of names and notes
    for (DocumentSnapshot snap in allDocs) {
      String uid = snap.id;

      //Not showing currUser Notes
      if(uid != widget.currUserUid.uid){
        //getting the userData of the note uploader
        DocumentSnapshot userSnap = await DatabaseService(uid: uid).getUserSnap();

        var listName=List<String>.from(snap.get('names'));
        var listLink=List<String>.from(snap.get('notes'));
        var listCourse=List<String>.from(snap.get('course'));
        var listSubject=List<String>.from(snap.get('subject'));
        var listDescription=List<String>.from(snap.get('description'));
        var listLikes=List<int>.from(snap.get('likes'));

        for (int i=0;i<listName.length;i++){
          //Creating Note objects from lists notes from snap
          allNotes.add(Note(
            name: listName[i],
            link: listLink[i],
            course: listCourse[i],
            subject: listSubject[i],
            userName:userSnap['username'],
            userDP: userSnap['profilePic'],
            userUid: uid,
            description: listDescription[i],
            likesCount: listLikes[i],
          ));
        }
      }
    }
    searchResultList();
  }

  searchResultList(){
    List<Note> showResults=[];
    //Shuffle the Notes randomly
    allNotes.shuffle();

    if(_searchController.text.isNotEmpty){
      //checking which Note object contains the subject text coming from search field
      for(Note note in allNotes){
        String? subject=note.subject?.toLowerCase();
        if(subject!.contains(_searchController.text.toLowerCase())){
          showResults.add(note);
        }
      }
    }
    else{
      showResults=allNotes;
    }

    setState(() {
      filteredNotes=showResults;
    });
  }


  @override
  void initState() {
    getAllNotes();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  //it will fire whenever there is a change in search field
  _onSearchChanged(){
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){

    final userDoc=Provider.of<DocumentSnapshot>(context);
    HashSet<String> liked=HashSet<String>.from(userDoc['liked']);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Search subject',
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: loadLength < filteredNotes.length ? loadLength : filteredNotes.length+1,
              itemBuilder: (context, index){
                int itemCount=loadLength < filteredNotes.length ? loadLength-1 : filteredNotes.length;
                if(index==itemCount){
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20.0,10.0,20.0,10.0),
                    child: ElevatedButton(
                      onPressed: (){
                        setState(() => loadLength+=10);
                      },
                      style: buttonStyleSignUp,
                      child: const Text(
                        'Load More',
                        style: TextStyle(
                        fontSize: 16.0,
                        ),
                      ),
                    ),
                  );
                }
                else{
                  final note=filteredNotes[index];
                  bool likedFlag=liked.contains(note.link);
                  // print(likedFlag);
                  //creating NotesTile
                  return NotesTile(
                    pdfLink: note.link,
                    name: note.name,
                    userDP: note.userDP,
                    userName: note.userName,
                    subject: note.subject,
                    course: note.course,
                    userUid: note.userUid,
                    description: note.description,
                    likedFlag: likedFlag,
                    likesCount: note.likesCount,
                  );
                }
              }
          ),
        ),
      ],
    );
  }
}
