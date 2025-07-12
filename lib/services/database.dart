import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  Future startFollowing(String following) async {
    List<String> followingList=[];

    // Fetch the existing notes data from the database
    DocumentSnapshot snapshot = await _userCollection.doc(uid).get();

    try {
      followingList = List<String>.from(snapshot.get('following'));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    followingList.add(following);
    _userCollection.doc(uid).set({
      'username': snapshot['username'],
      'email': snapshot['email'],
      'password': snapshot['password'],
      'profilePic': snapshot['profilePic'],
      'college': snapshot['college'],
      'course': snapshot['course'],
      'class': snapshot['class'],
      'bio': snapshot['bio'],
      'followers': snapshot['followers'],
      'following': followingList,
      'notesUploaded': snapshot['notesUploaded'],
      'liked': snapshot['liked']
    }
    );
  }

  Future stopFollowing(String following) async {
    List<String> followingList=[];

    // Fetch the existing notes data from the database
    DocumentSnapshot snapshot = await _userCollection.doc(uid).get();

    try {
      followingList = List<String>.from(snapshot.get('following'));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    followingList.remove(following);
    _userCollection.doc(uid).set({
      'username': snapshot['username'],
      'email': snapshot['email'],
      'password': snapshot['password'],
      'profilePic': snapshot['profilePic'],
      'college': snapshot['college'],
      'course': snapshot['course'],
      'class': snapshot['class'],
      'bio': snapshot['bio'],
      'followers': snapshot['followers'],
      'following': followingList,
      'notesUploaded': snapshot['notesUploaded'],
      'liked': snapshot['liked']
    }
    );
  }

  //upload the notes data of user in database
  Future updateNotesData(String? url, String? name, String? course, String? subject, String? description) async {
    List notesList=[];
    List notesName=[];
    List notesCourse=[];
    List notesSubject=[];
    List notesDescription=[];
    List notesLikes=[];
    try {
      // Fetch the existing notes data from the database
      DocumentSnapshot snapshot = await _notesCollection.doc(uid).get();

      try {
        notesList = List<String>.from(snapshot.get('notes'));
        notesName = List<String>.from(snapshot.get('names'));
        notesCourse = List<String>.from(snapshot.get('course'));
        notesSubject = List<String>.from(snapshot.get('subject'));
        notesDescription=List<String>.from(snapshot.get('description'));
        notesLikes=List<int>.from(snapshot.get('likes'));
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }

      // Add the new note to the list
      if (url != null && name != null) {
        //add url in list
        notesList.add(url);
        //add name of file in list
        notesName.add(name);
        //add course of file in list
        notesCourse.add(course);
        //add subject of file in list
        notesSubject.add(subject);
        //add description of file in list
        notesDescription.add(description);
        //add likes of file in list
        notesLikes.add(0);
      }
      // Update the notes data in the database
      await _notesCollection.doc(uid).set({
        'notes': notesList,
        'names': notesName,
        'course': notesCourse,
        'subject': notesSubject,
        'description': notesDescription,
        'likes': notesLikes,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notes data: $e');
      }
    }
  }

  //Deleteing user pdf from delete button
  Future deleteUserPDF({String? pdfUrl}) async {
    List notesList=[];
    List notesName=[];
    List notesCourse=[];
    List notesSubject=[];
    List notesDescription=[];
    List notesLikes=[];
    try {
      // Fetch the existing notes data from the database
      DocumentSnapshot snapshot = await _notesCollection.doc(uid).get();

      try {
        notesList = List<String>.from(snapshot.get('notes'));
        notesName = List<String>.from(snapshot.get('names'));
        notesCourse = List<String>.from(snapshot.get('course'));
        notesSubject = List<String>.from(snapshot.get('subject'));
        notesDescription=List<String>.from(snapshot.get('description'));
        notesLikes=List<int>.from(snapshot.get('likes'));
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }

      // Deleting the note from the list
      if (pdfUrl != null) {
        //finding the index of PDF from List
        int noteIdx=notesList.indexOf(pdfUrl);
        //removing all with index pdf's fields
        notesList.removeAt(noteIdx);
        notesName.removeAt(noteIdx);
        notesCourse.removeAt(noteIdx);
        notesSubject.removeAt(noteIdx);
        notesDescription.removeAt(noteIdx);
        notesLikes.removeAt(noteIdx);
      }
      // Update the notes data in the database
      await _notesCollection.doc(uid).set({
        'notes': notesList,
        'names': notesName,
        'course': notesCourse,
        'subject': notesSubject,
        'description': notesDescription,
        'likes': notesLikes,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notes data: $e');
      }
    }
  }

  //Updating the likes count from like button
  Future updatingLikes({String? pdfUrl, required bool likedFlag}) async {
    List notesList=[];
    List notesName=[];
    List notesCourse=[];
    List notesSubject=[];
    List notesDescription=[];
    List notesLikes=[];
    try {
      // Fetch the existing notes data from the database
      DocumentSnapshot snapshot = await _notesCollection.doc(uid).get();

      try {
        notesList = List<String>.from(snapshot.get('notes'));
        notesName = List<String>.from(snapshot.get('names'));
        notesCourse = List<String>.from(snapshot.get('course'));
        notesSubject = List<String>.from(snapshot.get('subject'));
        notesDescription=List<String>.from(snapshot.get('description'));
        notesLikes=List<int>.from(snapshot.get('likes'));

      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }

      // Deleting the note from the list
      if (pdfUrl != null) {
        //finding the index of PDF from List
        int noteIdx=notesList.indexOf(pdfUrl);
        //Increasing likes count
        int likesCount=notesLikes.elementAt(noteIdx);
        if(likedFlag){
          notesLikes[noteIdx]=--likesCount;
        }
        else{
          notesLikes[noteIdx]=++likesCount;
        }
      }
      // Update the notes data in the database
      await _notesCollection.doc(uid).set({
        'notes': notesList,
        'names': notesName,
        'course': notesCourse,
        'subject': notesSubject,
        'description': notesDescription,
        'likes': notesLikes,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating notes data: $e');
      }
    }
  }

  Future<DocumentSnapshot> getUserSnap()async {
    return await _userCollection.doc(uid).get();
  }

  Future<DocumentSnapshot> getNotesSnap()async {
    return await _notesCollection.doc(uid).get();
  }

  NotesModel? _notesOfUser(DocumentSnapshot? snap){
    try{
      return snap != null ? NotesModel(
        notesLink: List<String>.from(snap.get('notes')),
        notesName: List<String>.from(snap.get('names')),
        notesCourse: List<String>.from(snap.get('course')),
        notesSubject: List<String>.from(snap.get('subject')),
        notesDescription: List<String>.from(snap.get('description')),
        notesLikes: List<int>.from(snap.get('likes')),
      ) : null;
    }
    catch(e){
      return null;
    }
  }

  //get the notes of all Users
  Stream<QuerySnapshot> get allNotes{
    return _notesCollection.snapshots();
  }


  //get the notes of loggedIn user
  Stream<NotesModel?> get notesData{
    return _notesCollection.doc(uid).snapshots().map(
      _notesOfUser
    );
  }

  //get the data of the user
  Stream<DocumentSnapshot> get userData{
    return _userCollection.doc(uid).snapshots();
  }

}