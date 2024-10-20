import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key, this.pdfLink, this.name, this.userName, this.userDP,this.course,this.subject, this.userUid, this.description});

  final String? pdfLink;
  final String? name;
  final String? userName;
  final String? userDP;
  final String? course;
  final String? subject;
  final String? userUid;
  final String? description;

  Future<void> downloadFile(BuildContext context) async {
    // launching the pdfLink and it will automatically start downloading
    final Uri url = Uri.parse(pdfLink!);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }




  @override
  Widget build(BuildContext context) {
    final currentUserUid=Provider.of<UserUid?>(context);

    //checking if current user is trying to open its own profile
    bool flag=currentUserUid?.uid!=userUid;

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
                              'userUid': userUid,
                            });
                          },
                          child: CircleAvatar(
                            //if there is no dp then dont show image
                            backgroundImage: userDP !='No DP'? NetworkImage(
                              userDP!,
                            ): null,
                            radius: 30.0,
                          ),
                        ):CircleAvatar(
                          backgroundImage: userDP !='No DP'? NetworkImage(
                            userDP!,
                          ): null,
                          radius: 30.0,
                        ),
                        const SizedBox(height: 8), // Space between CircleAvatar and username
                        Text(
                          userName!,
                          style: const TextStyle(fontSize: 12.0), // Adjust the font size as needed
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            // const Spacer(),
                            IconButton(
                              onPressed: (){},
                              icon: const Icon(Icons.favorite),
                            ),
                            const Text("0"),
                            const Spacer(),
                            IconButton(
                              onPressed: ()async {
                                await downloadFile(context);
                              },
                              icon: const Icon(Icons.download,),
                            ),
                          ],
                        )
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
                        Text("$description"),
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
                        Text("$course"),
                      ],
                    )
                  ),
                  // SizedBox(width: 10.0,),
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
                          Text("$subject"),
                        ],
                      ),
                    )
                  ),
                  // Expanded(child: Center(child: Text("Course/Class:\n$course"))),
                  // Expanded(child: Center(child: Text("Subject:\n$subject"))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
