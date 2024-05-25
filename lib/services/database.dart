import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesgram/models/notesModel.dart';

class DatabaseService{
  
  final String? uid;
  
  DatabaseService({this.uid});

  //Colllection Reference
  //for users
  final CollectionReference _userCollection=FirebaseFirestore.instance
      .collection('users');
  //for notes Data
  final CollectionReference _notesCollection=FirebaseFirestore.instance
      .collection('notes');

  //upload the data of user in database
  Future updataUserData(String username, String email, String password, String? downloadUrl) async {
    return await _userCollection.doc(uid).set({
      'username': username,
      'email': email,
      'password': password,
      'profilePic': downloadUrl,
    });
  }
  List notesList=[];
  List notesName=[];
  //upload the notes data of user in database
  Future updataNotesData(String? url, String? name) async {
    try {
      // Fetch the existing notes data from the database
      DocumentSnapshot snapshot = await _notesCollection.doc(uid).get();

      try {
        notesList = List<String>.from(snapshot.get('notes'));
        notesName = List<String>.from(snapshot.get('names'));
      } catch (e) {

      }

      // Add the new note to the list
      if (url != null && name != null) {
        //add url in list
        notesList.add(url);
        //add name of file in list
        notesName.add(name);
      }
      // Update the notes data in the database
      await _notesCollection.doc(uid).set({
        'notes': notesList,
        'names': notesName,
      });
    } catch (e) {
      print('Error updating notes data: $e');
    }
  }

  //get the notes of the user
  // Stream<DocumentSnapshot> get notesData{
  //   return _notesCollection.doc(uid).snapshots();
  // }

  NotesModel? _notesofUser(DocumentSnapshot? snap){
    return snap != null ? NotesModel(notesDoc: List<String>.from(snap?.get('notes')),
        notesName: List<String>.from(snap?.get('names'))) : null;
  }

  Stream<NotesModel?> get notesData{
    return _notesCollection.doc(uid).snapshots().map(
      _notesofUser
    );
  }


  //get the data of the user
  Stream<DocumentSnapshot> get userData{
    return _userCollection.doc(uid).snapshots();
  }

}