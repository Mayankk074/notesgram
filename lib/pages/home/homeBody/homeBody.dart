import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notesgram/models/note.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatefulWidget {
  HomeBody({super.key, this.user});

  UserUid? user;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<Note> allNotes=[];

  Future followingNotes()async {

    allNotes.clear(); // clear old notes
    final box = await Hive.openBox<Note>('followingNotes_${widget.user?.uid}');

    // Cache data
    List<Note> cachedNotes=box.values.toList();

    if(cachedNotes.isEmpty){
      //get the followingNotes if it has not been cached yet.
      allNotes = await DatabaseService(uid: widget.user?.uid).followingNotes();
    }
    else{
      //start background refresh in background
      DatabaseService(uid: widget.user?.uid).followingNotes();
      //directly assign the cachedNotes
      allNotes=cachedNotes;
    }

    //Return if widget is disposed
    if(!mounted) return;

    setState(() {});
  }

  @override
  void initState() {
    followingNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDoc=Provider.of<DocumentSnapshot?>(context);
    HashSet<String> liked=HashSet<String>();

    //if userDoc is not fully populated
    if (userDoc != null && userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;

      if (data.containsKey('liked') && data['liked'] != null) {
        liked = HashSet<String>.from(data['liked']);
      }
    }

    return allNotes.isNotEmpty? ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (context, index) {
          Note note=allNotes[index];
          bool likedFlag=liked.contains(note.link);
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
            uploadedAt: note.uploadedAt,
            id: note.noteId,
            refreshCallback: followingNotes, //sending call back function to refresh the screen after following/unfollowing
            );
          }
    ):const Center(
      child: Text('You are not following anyone!!'),
    );
  }
}
