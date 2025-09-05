import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/notesTile.dart';
import 'package:notesgram/services/database.dart';
import 'package:provider/provider.dart';

import '../../../../models/note.dart';
import '../../../../models/userUid.dart';

class ReportedNotes extends StatefulWidget {
  const ReportedNotes({super.key});

  @override
  State<ReportedNotes> createState() => _ReportedNotesState();
}

class _ReportedNotesState extends State<ReportedNotes> {

  List<Note> reportedNotes=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReportedNotes();
  }

  void getReportedNotes()async{
    reportedNotes=await DatabaseService().reportedNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ReportedNotes'),
      ),
      body: reportedNotes.isEmpty ? Center(child: Text('No reports'),) : ListView.builder(
        itemCount: reportedNotes.length,
        itemBuilder: (context, index){
          final note=reportedNotes[index];
          return NotesTile(
            pdfLink: note.link,
            pdfPath: note.path,
            name: note.name,
            userDP: note.userDP,
            userName: note.userName,
            subject: note.subject,
            course: note.course,
            userUid: note.userUid,
            description: note.description,
            likedFlag: false,
            likesCount: note.likesCount,
            uploadedAt: note.uploadedAt,
            id: note.noteId,
          );
        }
      )
    );
  }
}
