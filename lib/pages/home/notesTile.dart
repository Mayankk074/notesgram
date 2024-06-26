import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key, this.pdfLink, this.name, this.userName, this.userDP,this.course,this.subject, this.userUid});

  final String? pdfLink;
  final String? name;
  final String? userName;
  final String? userDP;
  final String? course;
  final String? subject;
  final String? userUid;

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
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          children: [
            ListTile(
              //using the flag to show userProfile
              leading: flag? CupertinoButton(
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
              title: Text(name!),
              trailing: IconButton(
                onPressed: ()async {
                  await downloadFile(context);
                },
                icon: const Icon(Icons.download,),
              ),
            ),
            Row(
              children: [
                // SizedBox(width: 20,),
                Expanded(child: Center(child: Text(userName!))),
                // SizedBox(width: 30.0,),
                Expanded(child: Center(child: Text("Course/Class:\n$course"))),
                // SizedBox(width: 30.0,),
                Expanded(child: Center(child: Text("Subject:\n$subject"))),
              ],
            ),
            const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
