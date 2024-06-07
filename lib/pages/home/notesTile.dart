import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key, this.pdfLink, this.name, this.userName, this.userDP,this.course,this.subject});

  final String? pdfLink;
  final String? name;
  final String? userName;
  final String? userDP;
  final String? course;
  final String? subject;

  Future<void> downloadFile(BuildContext context) async {
    // launching the pdfLink and it will automatically start downloading
    final Uri url = Uri.parse(pdfLink!);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: Column(
          children: [
            ListTile(
              leading: CupertinoButton(
                padding: EdgeInsets.only(left: 5),
                onPressed: (){},
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userDP!,
                  ),
                  radius: 30.0,
                ),
              ),
              title: Text(name!),
              trailing: IconButton(
                onPressed: ()async {
                  await downloadFile(context);
                },
                icon: Icon(Icons.download,),
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
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
