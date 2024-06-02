import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key, this.pdfLink, this.name, this.userName, this.userDP,this.course,this.subject});

  final String? pdfLink;
  final String? name;
  final String? userName;
  final String? userDP;
  final String? course;
  final String? subject;


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
                padding: EdgeInsets.all(0),
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
                onPressed: () {  },
                icon: Icon(Icons.download,),
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 100.0,),
                Text("Course/Class:"),
                SizedBox(width: 50.0,),
                Text("Subject:"),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 20.0,),
                Text(userName!),
                SizedBox(width: 100.0,),
                Text(course!),
                SizedBox(width: 70.0,),
                Text(subject!),
              ],
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
