import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:provider/provider.dart';

class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {

    // final userDoc=Provider.of<DocumentSnapshot?>(context);
    final notesDocument=Provider.of<NotesModel?>(context);


    List<String>? notesList=notesDocument?.notesDoc;
    List<String>? notesNames=notesDocument?.notesName;
    // List notesList = List<String>.from(notesDoc?.get('notes'));

    return ListView.builder(
      itemCount: notesList != null ? notesList?.length : 0,
      itemBuilder: (context, index){
        return NotesTile(pdf: notesList?[index], name: notesNames?[index],);
      }
    );
    // return Container(
    //   child: Text(notesList[0]),
    // );
  }
}
