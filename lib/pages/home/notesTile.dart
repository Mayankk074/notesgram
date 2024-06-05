import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key, this.pdfLink, this.name, this.userName, this.userDP,this.course,this.subject});

  final String? pdfLink;
  final String? name;
  final String? userName;
  final String? userDP;
  final String? course;
  final String? subject;

  Future _downloadAndSaveFile(String url) async {
    // Dio dio = Dio();
    try {
      // Create a temporary directory to store the downloaded file

      Directory? tempDir = await getDownloadsDirectory();
      String? tempPath = tempDir?.path;

      // Download file
      // await dio.download(url, '$tempPath/$name');
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: '$tempPath',
        showNotification: true, // show download progress in status bar (for Android)
        // openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );

      // Return XFile
      // return XFile('$tempPath/$name');
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  void _openPdf(BuildContext context) async {
    // Check if the URL launcher is supported on the device
    if (await canLaunchUrlString(pdfLink!)) {
      XFile? file=await _downloadAndSaveFile(pdfLink!);
      // Prompt the user to choose an app to open the PDF with
      Share.shareXFiles([file!], text: 'Open PDF with...');
    } else {
      // Handle the case where the URL cannot be launched
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open PDF.'),
        ),
      );
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
                  _downloadAndSaveFile(pdfLink!);
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
