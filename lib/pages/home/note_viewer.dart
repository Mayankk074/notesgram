import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/database.dart';

class NoteViewer extends StatefulWidget {
  const NoteViewer({super.key});


  @override
  State<NoteViewer> createState() => _NoteViewerState();
}

class _NoteViewerState extends State<NoteViewer> {
  Map data = {};
  late DocumentSnapshot userDoc;
  String pdfLink="";
  String? userUid;
  bool likedFlag=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize variables in initState with the initial value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      data = ModalRoute.of(context)!.settings.arguments as Map;
      userDoc = data['userDoc'];
      pdfLink = data['pdfLink'];
      likedFlag = data['likedFlag'];
      userUid = data['userUid'];
      setState(() {}); // Update state after initializing
    });
  }

  Future<void> _downloadFile() async {
    // launching the pdfLink and it will automatically start downloading
    final Uri url = Uri.parse(pdfLink);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid=Provider.of<UserUid?>(context);
    bool currUserFlag=false;

    //prevention for initialization
    if(userUid != null){
      //checking if current user is also uploader of Note 'true means uploader'
      currUserFlag=currentUserUid?.uid == userUid;
    }

    //User won't be able to pop the screen via back button of system
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context, data['likesCount']);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text('${data['userName']}'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:25),
                  child: Text(
                    '${data['pdfName']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                //showing pdf preview using SyncFusion PDF Viewer
                Container(
                  height: 500,
                  color: Colors.amberAccent,
                  child: pdfLink.isNotEmpty ? SfPdfViewer.network(
                    pdfLink,
                  ): Container(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () async {
                        //checking if user has already liked the note
                        if (likedFlag) {
                          //removing the pdfLink from "liked" field
                          HashSet<String> liked =
                              HashSet<String>.from(userDoc['liked']);
                          liked.remove(pdfLink);
                          DatabaseService(uid: currentUserUid?.uid)
                              .updateUserData(
                                  userDoc['username'],
                                  userDoc['email'],
                                  userDoc['password'],
                                  userDoc['profilePic'],
                                  userDoc['college'],
                                  userDoc['course'],
                                  userDoc['class'],
                                  userDoc['bio'],
                                  userDoc['followers'],
                                  List<String>.from(userDoc['following']),
                                  userDoc['notesUploaded'],
                                  liked);
                          //Reversing the likedFlag
                          likedFlag=!likedFlag;
                          //decreasing the likesCount
                          data['likesCount']--;
                        } else {
                          //Adding pdfLink in "liked" field in the UserDoc of Liker
                          HashSet<String> liked =
                              HashSet<String>.from(userDoc['liked']);
                          liked.add(pdfLink);
                          DatabaseService(uid: currentUserUid?.uid)
                              .updateUserData(
                                  userDoc['username'],
                                  userDoc['email'],
                                  userDoc['password'],
                                  userDoc['profilePic'],
                                  userDoc['college'],
                                  userDoc['course'],
                                  userDoc['class'],
                                  userDoc['bio'],
                                  userDoc['followers'],
                                  List<String>.from(userDoc['following']),
                                  userDoc['notesUploaded'],
                                  liked);
                          likedFlag=!likedFlag;
                          //Increasing the likesCount
                          data['likesCount']++;
                        }
                        await DatabaseService(uid: userUid).updatingLikes(
                            likedFlag: !likedFlag, id: data['id']);
                        //Again rebuilding the widget for likesCount
                        setState(() {});
                      },
                      icon: Icon(
                        likedFlag ? Icons.favorite: Icons.favorite_border,
                        color: likedFlag ? Colors.red : Colors.grey,
                      ),
                      iconSize: 30,
                    ),
                    Text("${data['likesCount']}"),
                    const Spacer(),
                    if(currUserFlag) //show Delete button to the uploader only
                      IconButton(
                        onPressed: (){
                          //Asking for confirmation
                          showDialog(
                              context: context,
                              builder: (BuildContext dialogContext){
                                return AlertDialog(
                                  title: const Text('Alert!!'),
                                  content: const SingleChildScrollView(
                                      child: Text(
                                          'Do you really want to Delete?'
                                      )
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Yes'),
                                      onPressed: () async {
                                        await DatabaseService(uid: userUid).deleteUserPDF(id: data['id']);
                                        //Decreasing the no. of notesUploaded
                                        await DatabaseService(uid: userUid)
                                            .updateUserData(
                                            userDoc['username'],
                                            userDoc['email'],
                                            userDoc['password'],
                                            userDoc['profilePic'],
                                            userDoc['college'],
                                            userDoc['course'],
                                            userDoc['class'],
                                            userDoc['bio'],
                                            userDoc['followers'],
                                            List<String>.from(userDoc['following']),
                                            userDoc['notesUploaded']-1,
                                            HashSet<String>.from(userDoc['liked'])
                                        );
                                        if(!context.mounted) return;
                                        Navigator.of(dialogContext).pop();
                                        Navigator.of(context).pop();
                                        const snackBar = SnackBar(
                                          content: Text('Yay! Note has been deleted!'),
                                        );
                                        // Find the ScaffoldMessenger in the widget tree
                                        // and use it to show a SnackBar.
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    IconButton(
                      onPressed: () {
                        _downloadFile();
                      },
                      icon: const Icon(Icons.download),
                      iconSize: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("${data['description']}"),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Course/Class:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("${data['course']}"),
                        ],
                      )),
                      // SizedBox(width: 10.0,),
                      Expanded(
                          child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Subject:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("${data['subject']}"),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
