import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/notesModel1.dart';

class DatabaseService{
  
  final String? uid;
  
  DatabaseService({this.uid});

  //Colllection Reference
  //for users
  final CollectionReference _userCollection=FirebaseFirestore.instance
      .collection('users');

  Future<void> addNote({
    required String? fileName,
    required String? course,
    required String? subject,
    required String? description,
    required String? url,
    required int? likes
  }) async {

    final noteData = {
      'fileName': fileName,
      'course': course,
      'subject': subject,
      'description': description,
      'url': url,
      'likes': likes,
      'uploadedAt': FieldValue.serverTimestamp(),
    };

    // Path: users/{uid}/notes/{auto-generated-id}
    await _userCollection
        .doc(uid)
        .collection('notes')
        .add(noteData); // auto-generates a new doc ID
  }


  //upload the data of user in database
  Future updateUserData(String username, String email, String password, String? downloadUrl,String college, String course, String className, String bio,int followers,List<String> following, int notesUploaded, HashSet<String> liked) async {

    return await _userCollection.doc(uid).set({
      'username': username,
      'email': email,
      'password': password,
      'profilePic': downloadUrl,
      'college': college,
      'course': course,
      'class': className,
      'bio': bio,
      'followers': followers,
      'following': following,
      'notesUploaded': notesUploaded,
      'liked': liked
    });
  }

  Future startFollowing(String otherUserId) async {
    List<String> followingList=[];

    try {
      // Fetch the current user data from the database
      final userRef = _userCollection.doc(uid);
      DocumentSnapshot snapshot = await userRef.get();

      //Add other User id from the current user following list
      followingList = List<String>.from(snapshot.get('following'));
      followingList.add(otherUserId);
      await userRef.update({
        'following': followingList
      });

      //Increase the number of followers of other user
      DocumentSnapshot snap=await _userCollection.doc(otherUserId).get();
      int cnt=snap['followers'];
      await snap.reference.update({
        'followers': cnt+1
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future stopFollowing(String otherUserId) async {
    List<String> followingList=[];

    try {
      // Fetch the existing user data from the database
      final userRef = _userCollection.doc(uid);
      DocumentSnapshot snapshot = await userRef.get();

      //remove other User id from the current user following list
      followingList = List<String>.from(snapshot.get('following'));
      followingList.remove(otherUserId);
      await userRef.update({
        'following': followingList
      });

      //Decrease the number of followers of other user
      DocumentSnapshot snap=await _userCollection.doc(otherUserId).get();
      int cnt=snap['followers'];
      await snap.reference.update({
        'followers': cnt-1
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //updating the liked field according to isLiked
  Future liked(bool isLiked, String pdfLink) async {
    try {
      // Fetch the current user data from the database
      final userRef = _userCollection.doc(uid);
      DocumentSnapshot snapshot = await userRef.get();

      //Removing the pdfLink from liked field
      HashSet<String> liked = HashSet<String>.from(snapshot['liked']);
      if(isLiked){
        liked.remove(pdfLink);
      }else{
        liked.add(pdfLink);
      }

      //updating the liked field
      await userRef.update({
        'liked': liked
      });

    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Delete user pdf from delete button
  Future deleteUserPDF({String? id}) async {
    try {
      //getting the doc from subCollection
      DocumentSnapshot snap=await _userCollection.doc(uid).collection('notes').doc(id).get();
      await snap.reference.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notes data: $e');
      }
    }
  }

  //Update the likes count from like button
  Future updatingLikes({required bool likedFlag, required String id}) async {
    try {
      // Fetch the existing notes data from the database
      //fetching the reference of document
      final noteRef=_userCollection.doc(uid).collection('notes').doc(id);
      DocumentSnapshot snapshot = await noteRef.get();
      if (snapshot.exists) {
        final currentLikes = snapshot.get('likes') ?? 0;
        final updatedLikes = likedFlag ? currentLikes - 1 : currentLikes + 1;

        //updating the likes field only by reference
        await noteRef.update({
          'likes': updatedLikes,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notes data: $e');
      }
    }
  }

  Future<DocumentSnapshot> getUserSnap()async {
    return await _userCollection.doc(uid).get();
  }

  //get the notes of loggedIn user  via subCollection
  Stream<List<NotesModel1?>> get notesData1{
    return _userCollection.doc(uid).collection('notes').snapshots().map(
        _notesOfUser1
    );
  }

  Future<List<NotesModel1?>> notesDataFromCollection()async{
    QuerySnapshot snap= await _userCollection.doc(uid).collection('notes').get();
    return _notesOfUser1(snap);
  }

  //Saving the note inside SavedNotes subCollection
  Future savedNote(String noteId, String ownerId)async{
    await _userCollection.doc(uid)
        .collection('savedNotes')
        .doc(noteId) // use original note's ID
        .set({
    'noteId': noteId,
    'ownerId': ownerId, // original creator's userId
    'savedAt': FieldValue.serverTimestamp(),
    });
  }

  List<NotesModel1?> _notesOfUser1(QuerySnapshot? snap){
    List<NotesModel1?> allNotes=[];
    try{
      List<DocumentSnapshot>? allDocs = snap?.docs;
      for(DocumentSnapshot doc in allDocs!){
        allNotes.add(NotesModel1(
          uid: doc.id,
          notesLikes: doc.get('likes'),
          notesDescription: doc.get('description'),
          notesCourse: doc.get('course'),
          notesLink: doc.get('url'),
          notesName: doc.get('fileName'),
          notesSubject: doc.get('subject')
          )
        );
      }
      return allNotes;
    }
    catch(e){
      return allNotes;
    }
  }

  //get the data of the user
  Stream<DocumentSnapshot> get userData{
    return _userCollection.doc(uid).snapshots();
  }

}