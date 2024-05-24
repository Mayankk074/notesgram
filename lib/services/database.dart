import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  
  final String? uid;
  
  DatabaseService({this.uid});

  //Colllection Reference
  final CollectionReference _userCollection=FirebaseFirestore.instance
      .collection('users');

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
  //upload the notes data of user in database
  Future updataNotesData(String? url) async {
    try {
      // Fetch the existing notes data from the database
      DocumentSnapshot snapshot = await _notesCollection.doc(uid).get();


      notesList = List<String>.from(snapshot.get('notes'));

      // Add the new note to the list
      if (url != null) {
        notesList.add(url);
      }
      // Update the notes data in the database
      await _notesCollection.doc(uid).set({
        'notes': notesList,
      });
    } catch (e) {
      print('Error updating notes data: $e');
    }
  }

  //get the data of the user
  Stream<DocumentSnapshot> get userData{
    return _userCollection.doc(uid).snapshots();
  }

}