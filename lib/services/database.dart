import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:notesgram/services/storage.dart';

import '../models/note.dart';
import '../models/notesModel.dart';

class DatabaseService{
  
  final String? uid;
  
  DatabaseService({this.uid});

  //Collection Reference
  //for users
  final CollectionReference _userCollection=FirebaseFirestore.instance
      .collection('users');

  Future<void> addNote({
    required File? file,
    required String? fileName,
    required String? course,
    required String? subject,
    required String? description,
    required int? likes
  }) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    //uploading the pdf to firebase storage ( start upload immediately)
    final uploadFuture =
    StorageServices(uid: uid).uploadPdf(file);

    // Path: users/{uid}/notes/{auto-generated-id} (prepare note doc ref while upload is happening)
    final noteDoc=_userCollection
        .doc(uid)
        .collection('notes')
        .doc(); // auto-generates a new doc ID

    // wait for upload to complete
    final result = await uploadFuture;

    final noteData = {
      'fileName': fileName,
      'course': course,
      'subject': subject,
      'description': description,
      'url': result['url'],
      'path': result['path'],
      'likes': likes,
      'uploadedAt': FieldValue.serverTimestamp(),
      'savedBy': []
    };

    batch.set(noteDoc, noteData);

    //Increasing no. of uploads
    batch.update(_userCollection.doc(uid), {
      'notesUploaded': FieldValue.increment(1)
    });

    await batch.commit();
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
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      // Fetch the current user data from the database
      final userRef = _userCollection.doc(uid);

      // //Add other User id from the current user following list
      batch.update(userRef, {
        'following': FieldValue.arrayUnion([otherUserId])
      });

      //Increase the number of followers of other user
      batch.update(_userCollection.doc(otherUserId), {
        'followers': FieldValue.increment(1)
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future stopFollowing(String otherUserId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      // Fetch the existing user data from the database
      final userRef = _userCollection.doc(uid);
      DocumentSnapshot snapshot = await userRef.get();

      //remove other User id from the current user following list
      batch.update(userRef, {
        'following': FieldValue.arrayRemove([otherUserId])
      });

      //Decrease the number of followers of other user
      // DocumentSnapshot snap=await _userCollection.doc(otherUserId).get();
      // int cnt=snap['followers'];
      batch.update(_userCollection.doc(otherUserId), {
        'followers': FieldValue.increment(-1)
      });

      await batch.commit();

    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //updating the liked field according to isLiked
  Future liked(bool isLiked, String pdfLink) async  {
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
  Future deleteUserPDF({required String id, required String filePath}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      // Get note's savedBy list
      DocumentSnapshot noteSnap = await _userCollection.doc(uid)
          .collection('notes')
          .doc(id)
          .get();

      //Reports
      final reportsSnap = await _userCollection
          .doc(uid)
          .collection("notes")
          .doc(id)
          .collection("reports")
          .get();

      //Deleting all Reports as well with note
      for (var doc in reportsSnap.docs) {
        batch.delete(doc.reference);
      }

      if (!noteSnap.exists) return;

      //It directly returning a List because it is List<dynamic>,
      // otherwise if you save List<String> it will return Iterable<String>
      List savedBy = noteSnap['savedBy'] ?? [];

      // Delete note from owner's notes
      batch.delete(_userCollection.doc(uid).collection('notes').doc(id));

      // Remove from each user's savedNotes
      for (String userId in savedBy) {
        batch.delete(_userCollection.doc(userId).collection('savedNotes').doc(id));
      }

      //decreasing the no. of uploads
      batch.update(_userCollection.doc(uid), {
        'notesUploaded': FieldValue.increment(-1)
      });

      // Commit all operations together
      await batch.commit();

      //Delete file from firebaseStorage as well
      StorageServices(uid: uid).deletePdf(filePath);
    } catch (e) {
      if (kDebugMode) {
        print('Error while deleting note: $e');
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
  Stream<List<NotesModel?>> get notesData{
    return _userCollection.doc(uid).collection('notes').snapshots().map(
        _notesOfUser
    );
  }

  Future<List<NotesModel?>> notesDataFromCollection()async{
    QuerySnapshot snap= await _userCollection.doc(uid).collection('notes').get();
    return _notesOfUser(snap);
  }

  //Saving the note inside SavedNotes subCollection
  Future saveNote(String noteId, String ownerId)async{
    //for transactional operations : Either all operations succeed, or none of them are applied
    WriteBatch batch = FirebaseFirestore.instance.batch();
    // Add to current user's savedNotes
    batch.set(
      _userCollection.doc(uid).collection('savedNotes').doc(noteId),
      {'noteId': noteId, 'ownerId': ownerId, 'savedAt': FieldValue.serverTimestamp()},
    );

    // Add currentUserId to owner's note's savedBy array
    batch.update(
      _userCollection.doc(ownerId).collection('notes').doc(noteId),
      {'savedBy': FieldValue.arrayUnion([uid])},
    );

    await batch.commit();
    final box = await Hive.openBox<Note>('savedNotesBox_$uid');
    // Start background refresh from Firestore
    _refreshSavedNotes(box);
  }
  //Unsaving the note inside SavedNotes subCollection
  Future unsaveNote(String noteId)async{
    await _userCollection.doc(uid)
        .collection('savedNotes')
        .doc(noteId) // use original note's ID
        .delete();
    final box = await Hive.openBox<Note>('savedNotesBox_$uid');
    // Start background refresh from Firestore
    _refreshSavedNotes(box);
  }

  Future<bool> isNoteSaved(String noteId) async {
    final doc = await _userCollection.doc(uid)
        .collection('savedNotes')
        .doc(noteId)
        .get();
    return doc.exists;
  }

  List<NotesModel?> _notesOfUser(QuerySnapshot? snap){
    List<NotesModel?> allNotes=[];
    try{
      List<DocumentSnapshot>? allDocs = snap?.docs;
      for(DocumentSnapshot doc in allDocs!){
        allNotes.add(NotesModel(
          uid: doc.id,
          notesLikes: doc.get('likes'),
          notesDescription: doc.get('description'),
          notesCourse: doc.get('course'),
          notesLink: doc.get('url'),
          notesPath: doc.get('path'),
          notesName: doc.get('fileName'),
          notesSubject: doc.get('subject'),
          uploadedAt: doc.get('uploadedAt').toDate()
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

  //Getting savedNotes from the 'savedNotes' subCollection
  Stream<List<Note>> getSavedNotes() async* {

    final box = await Hive.openBox<Note>('savedNotesBox_$uid');

    // Emit cached data first
    yield box.values.toList();

    // Start background refresh from Firestore
    _refreshSavedNotes(box);

    // Emit whenever cache changes
    yield* box.watch().map((_) => box.values.toList());
  }

  Future<void> _refreshSavedNotes(Box<Note> box) async{
    List<Note> result=[];
    QuerySnapshot snapshots= await _userCollection.doc(uid).collection('savedNotes').get();
    for(DocumentSnapshot snap in snapshots.docs){
      try{
        DocumentSnapshot user=await _userCollection.doc(snap['ownerId']).get();
        DocumentSnapshot note=await _userCollection.doc(snap['ownerId']).collection('notes').doc(snap['noteId']).get();
        result.add(Note(
            name: note['fileName'],
            link: note['url'],
            course: note['course'],
            subject: note['subject'],
            userName: user['username'],
            userDP: user['profilePic'],
            userUid: snap['ownerId'],
            description: note['description'],
            likesCount: note['likes'],
            uploadedAt: note['uploadedAt'].toDate(),
            noteId: snap.id
        )
        );
      }
      catch(e){
        if (kDebugMode) {
          print('Error while getting saved notes: $e');
        }
      }
    }
    // Clear old cache & save new
    await box.clear();
    await box.addAll(result);
  }

  Future<List<Note>> getAllNotes() async {
    List<Note> allNotes=[];
    final box = await Hive.openBox<Note>('allNotes_$uid');
    // Get all documents from all 'notes' subCollections (across all users)
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collectionGroup('notes')
        .get();

    for (DocumentSnapshot snap in snapshot.docs) {
      // Get the full path like: users/abc123/notes/noteDocId
      String fullPath = snap.reference.path;
      List<String> segments = fullPath.split('/');
      String userUid = segments[1]; // users/{uid}/notes/{noteId}

      // Skip if current user
      if (userUid != uid) {
        // Get user data
        DocumentSnapshot userSnap = await DatabaseService(uid: userUid).getUserSnap();

        // Create Note object from fields
        allNotes.add(Note(
            name: snap['fileName'],
            link: snap['url'],
            course: snap['course'],
            subject: snap['subject'],
            userName: userSnap['username'],
            userDP: userSnap['profilePic'],
            userUid: userUid,
            description: snap['description'],
            likesCount: snap['likes'],
            uploadedAt: snap['uploadedAt'].toDate(),
            noteId: snap.id
        ));
      }
    }
    await box.clear();
    await box.addAll(allNotes);
    return allNotes;
  }

  Future<List<Note>> followingNotes()async {
    List<Note> allNotes=[];
    List<String> followingList=[];
    final box = await Hive.openBox<Note>('followingNotes_$uid');
    DocumentSnapshot snap=await getUserSnap();

    //for first time user where there will be delay in profile pic upload for that error handling
    if(snap.data() != null){
      final data = snap.data() as Map<String, dynamic>;
      if (!data.containsKey('following') && data['following'] == null) {
        return allNotes;
      }
    }
    else{
      return allNotes;
    }

    followingList=List<String>.from(snap['following']);

    for(String otherUid in followingList){
      //userDetails of followed user.
      DocumentSnapshot userSnap=await DatabaseService(uid: otherUid).getUserSnap();
      //getting all Notes of user from following list.
      List<NotesModel?> notesList =await DatabaseService(uid: otherUid).notesDataFromCollection();

      for(int i=0;i<notesList.length;i++){
        //Creating Note objects from lists notes from snap
        allNotes.add(Note(
            name: notesList[i]!.notesName,
            link: notesList[i]!.notesLink,
            course: notesList[i]!.notesCourse,
            subject: notesList[i]!.notesSubject,
            userName:userSnap['username'],
            userDP: userSnap['profilePic'],
            userUid: otherUid,
            description: notesList[i]!.notesDescription,
            likesCount: notesList[i]!.notesLikes,
            uploadedAt: notesList[i]!.uploadedAt,
            noteId: notesList[i]!.uid
        ));
      }
    }

    await box.clear();
    await box.addAll(allNotes);

    return allNotes;
  }

  Future<void> report(String noteId, String currUserId) async{
    final reportRef = _userCollection
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .collection('reports')
        .doc(currUserId); // user can only report once

    await reportRef.set({
      'userId': currUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'reason': 'Inappropriate content', // later you can add dropdown for reasons
    });
  }

  Future<List<Note>> reportedNotes() async{
    List<Note> reportedNotes=[];

    // Get all documents from all 'notes' subCollections (across all users)
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collectionGroup('notes')
        .get();

    for (DocumentSnapshot snap in snapshot.docs) {
      print(snap.id);
      // Get the full path like: users/abc123/notes/noteDocId
      String fullPath = snap.reference.path;
      List<String> segments = fullPath.split('/');
      String userUid = segments[1]; // users/{uid}/notes/{noteId}

      DocumentSnapshot userSnap=await DatabaseService(uid: userUid).getUserSnap();

      final query=snap.reference.collection('reports').count();
      final querySnap=await query.get();

      if(querySnap.count! > 5){
        reportedNotes.add(Note(
            name: snap['fileName'],
            link: snap['url'],
            path: snap['path'],
            course: snap['course'],
            subject: snap['subject'],
            userName: userSnap['username'],
            userDP: userSnap['profilePic'],
            userUid: userUid,
            description: snap['description'],
            likesCount: snap['likes'],
            uploadedAt: snap['uploadedAt'].toDate(),
            noteId: snap.id
        ));
      }
    }

    return reportedNotes;
  }
}