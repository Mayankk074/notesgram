
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:provider/provider.dart';

class NotesTile extends StatefulWidget {
  NotesTile({super.key, this.pdfLink, this.name, this.userName, this.userDP,this.course,this.subject, this.userUid, this.description, required this.likedFlag, required this.likesCount, this.currUserDoc});

  final String? pdfLink;
  final String? name;
  final String? userName;
  final String? userDP;
  final String? course;
  final String? subject;
  final String? userUid;
  final String? description;
  final bool likedFlag;
  int? likesCount;
  DocumentSnapshot? currUserDoc;

  @override
  State<NotesTile> createState() => _NotesTileState();
}

class _NotesTileState extends State<NotesTile> {

  @override
  Widget build(BuildContext context) {
    final currentUserUid=Provider.of<UserUid?>(context);
    final userDoc=Provider.of<DocumentSnapshot?>(context);

    //checking if current user is also uploader of Note 'true means different user'
    bool flag=currentUserUid?.uid != widget.userUid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        flag? CupertinoButton(
                          padding: const EdgeInsets.only(left: 5),
                          onPressed: (){
                            Navigator.pushNamed(context, '/userProfile',arguments: {
                              'userUid': widget.userUid,
                            });
                          },
                          child: CircleAvatar(
                            //if there is no dp then dont show image
                            backgroundImage: widget.userDP !='No DP'? NetworkImage(
                              widget.userDP!): null,
                            radius: 30.0,
                            backgroundColor: Colors.purple[100],
                            child: widget.userDP != 'No DP' ?
                              null : const Icon(Icons.person,),
                          ),
                        ):CircleAvatar(
                          backgroundImage: widget.userDP !='No DP'? NetworkImage(
                            widget.userDP!): null,
                          radius: 30.0,
                          backgroundColor: Colors.purple[100],
                          child: widget.userDP != 'No DP' ? null : const Icon(Icons.person),
                        ),
                        const SizedBox(height: 8), // Space between CircleAvatar and username
                        Text(
                          widget.userName!,
                          style: const TextStyle(fontSize: 12.0), // Adjust the font size as needed
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () async {
                            //Getting back the likesCount so it would update the value
                            var result=await Navigator.pushNamed(context, '/singleNote', arguments: {
                                                  'userName': widget.userName,
                                                  'pdfName': widget.name,
                                                  'pdfLink': widget.pdfLink,
                                                  'userDoc': userDoc ?? widget.currUserDoc, //for otherUserFiles widget because it becomes null
                                                  'userUid': widget.userUid,
                                                  'likedFlag': widget.likedFlag,
                                                  'likesCount': widget.likesCount,
                                                  'course': widget.course,
                                                  'subject': widget.subject,
                                                  'description': widget.description,
                                                });
                            //updating the value with newer one
                            if(result != null){
                              widget.likesCount=result as int? ;
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                          ),
                          child: Text(
                            '${widget.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("${widget.description}"),
                      ],
                    )
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Course/Class:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("${widget.course}"),
                      ],
                    )
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Subject:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("${widget.subject}"),
                        ],
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
