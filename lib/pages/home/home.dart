import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/profile/profile.dart';
import 'package:notesgram/services/auth.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/services/storage.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int currentIndex=0;


  @override
  Widget build(BuildContext context) {
    final user=Provider.of<UserUid>(context);

    return StreamProvider<DocumentSnapshot?>.value(
      value: DatabaseService(uid: user.uid).userData,
      initialData: null,
      child: Scaffold(
        body: [Center(
          child: ElevatedButton(
            onPressed: (){
              AuthService().signOut();
            },
            child: Text('Logout'),
          ),
        ),
          Center(
            child: ElevatedButton(
              onPressed: (){

              },
              child: Text('Search'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                //picking the notes pdf
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  XFile? file = result.files.first.xFile;
                  File pdf=File(file.path);

                  //uploading the pdf to firebase storage
                  String url=await StorageServices(uid: user.uid).uploadPdf(pdf);

                  //updating the database with pdf url
                  await DatabaseService(uid: user.uid).updataNotesData(url);
                } else {
                  // User canceled the picker
                  print('user cancelled the picker');
                }
              },
              child: Text('Upload'),
            ),
          ),
          Profile(),
        ][currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (int index){
            setState(() {
              currentIndex=index;
            });
          },
          currentIndex: currentIndex,
          iconSize: 30.0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: ''
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: ''
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.upload),
                label: ''
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: ''
            ),
          ],
        ),
      ),
    );
  }
}
