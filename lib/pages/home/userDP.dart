import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  Map data={};
  DocumentSnapshot? userSnap;
  DocumentSnapshot? notesSnap;
  DocumentSnapshot? currentUserSnap;
  UserUid? userUid;
  bool isFollow=false;

  Future getUserProfile() async {
    userSnap= await DatabaseService(uid: data['userUid']).getUserSnap();
    notesSnap= await DatabaseService(uid: data['userUid']).getNotesSnap();
    //getting the current user snap who is logged in
    currentUserSnap= await DatabaseService(uid: userUid?.uid).getUserSnap();
    List<String> followingList=List<String>.from(currentUserSnap?['following']);
    //checking if user is already following that other user
    if(followingList.contains(data['userUid'])){
      isFollow=true;
    }
  }
  @override
  Widget build(BuildContext context) {

    //getting the userUid of the user whose profile to be shown
    data=ModalRoute.of(context)!.settings.arguments as Map;

    userUid=Provider.of<UserUid>(context);

    return FutureBuilder(
      future: getUserProfile(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingShared();
        } else if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(userSnap?['username']),
          ),
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70.0,
                  backgroundImage: userSnap?['profilePic'] != 'No DP' ?
                  NetworkImage(userSnap?['profilePic']):
                  null,
                ),
                Text(
                  userSnap?['username'],
                  style: const TextStyle(
                    fontSize: 25.0,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  userSnap?['email'],
                  style: const TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20.0,),
                Row(
                  children: [
                    const SizedBox(width: 70,),
                    Text(
                      '${userSnap?['followers']}',
                      style: const TextStyle(
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(width: 140,),
                    Text(
                      '${userSnap?['following'].length}',
                      style: const TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(width: 40,),
                    Text("Followers"),
                    SizedBox(width: 110,),
                    Text("Following")
                  ],
                ),
                const SizedBox(height: 20.0,),
                Text(
                  '${userSnap?['notesUploaded']}',
                  style: const TextStyle(
                    fontSize: 40.0,
                  ),
                ),
                const Text("PDFs Uploaded"),
                const SizedBox(height: 50,),
                ElevatedButton(
                  onPressed:()async{
                    setState(() => isFollow=!isFollow);
                    List<String> followingList=List<String>.from(userSnap?['following']);
                    if(isFollow){
                      //increase the no. of followers of another user
                      await DatabaseService(uid: data['userUid'] ).updateUserData(
                          userSnap?['username'], userSnap?['email'], userSnap?['password'],
                          userSnap?['profilePic'],userSnap?['college'],
                          userSnap?['course'],
                          userSnap?['class'],
                          userSnap?['bio'], userSnap?['followers']+1, followingList, userSnap?['notesUploaded'],HashSet<String>.from(userSnap?['liked']));
                      //adding the other user uid in the following
                      await DatabaseService(uid: userUid?.uid ).startFollowing(data['userUid']);
                    }else{
                      //decrease the no. of followers of another user
                      await DatabaseService(uid: data['userUid'] ).updateUserData(
                          userSnap?['username'], userSnap?['email'], userSnap?['password'],
                          userSnap?['profilePic'],userSnap?['college'],
                        userSnap?['course'],
                        userSnap?['class'],
                        userSnap?['bio'], userSnap?['followers']-1, followingList, userSnap?['notesUploaded'],HashSet<String>.from(userSnap?['liked']),);
                      //removing the other userUid in the following
                      await DatabaseService(uid: userUid?.uid ).stopFollowing(data['userUid']);
                    }
                  },
                  style: buttonStyleSignUp,
                  child: Text(
                    isFollow?'Following':'Follow',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 50,),
                ElevatedButton(
                  onPressed:(){
                    Navigator.pushNamed(context, '/otherUserFiles',arguments: {
                      'userSnap':userSnap,
                      'notesSnap':notesSnap,
                      'currentUserSnap':currentUserSnap
                    });
                  },
                  style: buttonStyleSignIn,
                  child: const Text(
                    'Uploaded Files',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
