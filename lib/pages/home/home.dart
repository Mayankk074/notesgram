import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/explore/explore.dart';
import 'package:notesgram/pages/home/profile/profile.dart';
import 'package:notesgram/pages/home/upload.dart';
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
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserUid>(context);

    return MultiProvider(
      providers: [
        //listening to user data
        StreamProvider<DocumentSnapshot?>.value(
          value: DatabaseService(uid: user.uid).userData,
          initialData: null,
        ),
        
        //listening to user notes
        StreamProvider<NotesModel?>.value(
          value: DatabaseService(uid: user.uid).notesData,
          initialData: null,
        ),

        //listening to all user notes
        StreamProvider<QuerySnapshot?>.value(
          value: DatabaseService(uid: user.uid).allNotes,
          initialData: null,
        ),
      ],
      child: Scaffold(
        body: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                AuthService().signOut();
              },
              child: Text('Logout'),
            ),
          ),
          Explore(),
          Container(
            child: Notes(),
          ),
          Profile(),
        ][currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          currentIndex: currentIndex,
          iconSize: 30.0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.upload), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }
}
