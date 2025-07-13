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
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;

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
                Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth*0.12,
                      backgroundImage: userSnap?['profilePic'] != 'No DP' ?
                      NetworkImage(userSnap?['profilePic']):
                      null,
                      backgroundColor: Colors.purple[100],
                      child: userSnap?['profilePic'] != 'No DP' ?
                        null : const Icon(Icons.person, size: 140),
                    ),
                    SizedBox(
                      width: screenWidth*0.07,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userSnap?['username'],
                            style: TextStyle(
                                fontSize: screenWidth*0.045,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            userSnap?['college'],
                            style: TextStyle(
                              fontSize: screenWidth*0.045,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '${userSnap?['course']} ${userSnap?['class']}',
                            style: TextStyle(
                              fontSize: screenWidth*0.045,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight*0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      userSnap?['bio'],
                      style: TextStyle(
                        fontSize: screenWidth*0.045,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight*0.1),
                const Divider(),
                Row(
                  children: [
                    SizedBox(width: screenWidth*0.05,),
                    Text(
                      '${userSnap?['followers']}',
                      style: TextStyle(
                        fontSize: screenWidth*0.1,
                      ),
                    ),
                    SizedBox(width: screenWidth*0.2,),
                    Text(
                      "Followers",
                      style: TextStyle(
                          fontSize: screenWidth*0.065,
                          letterSpacing: 1
                      ),
                    ),
                  ],
                ),//end
                SizedBox(height: screenHeight*0.01,),
                Row(
                  children: [
                    SizedBox(width: screenWidth*0.05,),
                    Text(
                      '${userSnap?['following'].length}',
                      style: TextStyle(
                        fontSize: screenWidth*0.1,
                      ),
                    ),
                    SizedBox(width: screenWidth*0.2,),
                    Text(
                      "Following",
                      style: TextStyle(
                          fontSize: screenWidth*0.065,
                          letterSpacing: 1
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenHeight*0.01,),
                Row(
                  children: [
                    SizedBox(width: screenWidth*0.05,),
                    Text(
                      '${userSnap?['notesUploaded']}',
                      style: TextStyle(
                        fontSize:screenWidth*0.1,
                      ),
                    ),
                    SizedBox(width: screenWidth*0.2,),
                    Flexible(
                      child: Text(
                        "PDFs Uploaded",
                        style: TextStyle(
                            fontSize: screenWidth*0.065,
                            letterSpacing: 1
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                SizedBox(height: screenHeight*0.1,),
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
                SizedBox(height: screenHeight*0.03,),
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
