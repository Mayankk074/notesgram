import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:notesgram/models/note.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';


class AllNotes extends StatefulWidget {
  const AllNotes({super.key});

  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {
  //Lists of Note object to be displayed
  List<Note> allNotes=[];
  List<Note> filteredNotes=[];

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

      //getting the userData of the note uploader
      DocumentSnapshot userSnap = await DatabaseService(uid: uid).getUserSnap();

      var listName=List<String>.from(snap.get('names'));
      var listLink=List<String>.from(snap.get('notes'));
      var listCourse=List<String>.from(snap.get('course'));
      var listSubject=List<String>.from(snap.get('subject'));

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
          ));
      }
    }
    searchResultList();
  }

  searchResultList(){
    List<Note> showResults=[];

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
    return Column(
      children: [
        CupertinoSearchTextField(
          controller: _searchController,
          placeholder: 'Search subject',
        ),
        Expanded(
          child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index){
                final note=filteredNotes[index];
                //creating NotesTile
                return NotesTile(
                  pdfLink: note.link,
                  name: note.name,
                  userDP: note.userDP,
                  userName: note.userName,
                  subject: note.subject,
                  course: note.course,
                  userUid: note.userUid,
                );
              }
          ),
        ),
      ],
    );
  }
}
