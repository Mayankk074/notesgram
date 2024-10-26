import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/notesModel.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/explore/explore.dart';
import 'package:notesgram/pages/home/homeBody/homeBody.dart';
import 'package:notesgram/pages/home/profile/profile.dart';
import 'package:notesgram/pages/home/upload/upload.dart';
import 'package:notesgram/services/database.dart';
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
      ],
      child: Scaffold(
        body: [
          HomeBody(user: user,),
          const Explore(),
          const Notes(),
          const Profile(),
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
          selectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Uploads'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
