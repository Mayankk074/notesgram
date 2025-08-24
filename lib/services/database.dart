import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/note.dart';
import '../models/notesModel.dart';

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
      'savedBy': []
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
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      // Get note's savedBy list
      DocumentSnapshot noteSnap = await _userCollection.doc(uid)
          .collection('notes')
          .doc(id)
          .get();

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
      DocumentSnapshot userSnap=await _userCollection.doc(uid).get();
      int notesUploaded=userSnap['notesUploaded'] ?? 0;

      batch.update(userSnap.reference, {
        'notesUploaded': notesUploaded > 0 ? notesUploaded -1 : 0
      });

      // Commit all operations together
      await batch.commit();
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
    final box = await Hive.openBox<Note>('allNotes');
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
}