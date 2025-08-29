
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/cachedPdfViewer.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../services/database.dart';
import '../../shared/constants.dart';

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
  String? noteId;
  bool isLiked=false;
  bool isSaved=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize variables in initState with the initial value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      data = ModalRoute.of(context)!.settings.arguments as Map;
      userDoc = data['userDoc'];
      pdfLink = data['pdfLink'];
      isLiked = data['likedFlag'];
      userUid = data['userUid'];
      noteId=data['id'];
      _isNoteSaved();
      setState(() {}); // Update state after initializing
    });
  }

  //Checking if note is Saved or not
  Future _isNoteSaved()async{
    final currentUserId=Provider.of<UserUid?>(context, listen: false);
    if(currentUserId != null) {
      isSaved = await DatabaseService(uid: currentUserId.uid).isNoteSaved(noteId!);
    }
    setState(() {});
  }

  //Saving/unsaving note
  Future<void> _toggleSave(String? currentUserUid) async {
    if (isSaved) {
      await DatabaseService(uid: currentUserUid).unsaveNote(noteId!);
    } else {
      await DatabaseService(uid: currentUserUid)
          .saveNote(noteId!, userUid!);
    }

    setState(() {
      isSaved = !isSaved;
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
            actions: [
              IconButton(
                icon: Icon(Icons.flag, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Report Note"),
                      content: Text("Do you want to report this note as inappropriate?"),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          style: buttonStyleSignUp,
                          child: Text("Cancel"),
                        ),
                        SizedBox(height: 10,),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Report submitted")),
                            );
                          },
                          style: buttonStyleSignIn,
                          child: Text("Report"),
                        ),
                      ],
                    ),
                  );
                },
              )

            ],
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
                  color: Colors.purple[200],
                  child: pdfLink.isNotEmpty ? CachedPdfViewer(pdfUrl: pdfLink): Container(),
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
                        DatabaseService(uid: currentUserUid?.uid)
                            .liked(isLiked, pdfLink);
                        //checking if user has already liked the note
                        if (isLiked) {
                          //Reversing the likedFlag
                          isLiked=!isLiked;
                          //decreasing the likesCount
                          data['likesCount']--;
                        } else {
                          isLiked=!isLiked;
                          //Increasing the likesCount
                          data['likesCount']++;
                        }
                        await DatabaseService(uid: userUid).updatingLikes(
                            likedFlag: !isLiked, id: noteId!);
                        //Again rebuilding the widget for likesCount
                        setState(() {});
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite: Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      iconSize: 30,
                    ),
                    Text("${data['likesCount']}"),
                    Spacer(),
                    Text(
                      data['uploadedAt'] == null ? '' : DateFormat("d MMMM yyyy").format(data['uploadedAt']),
                      textAlign: TextAlign.center, // centers inside Expanded
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    //Saving the Note in savedNotes for currentUser
                    IconButton(
                      onPressed:(){
                        _toggleSave(currentUserUid!.uid);
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border)
                      ),
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
                                        await DatabaseService(uid: userUid).deleteUserPDF(id: data['id'], filePath: data['pdfPath']);
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
