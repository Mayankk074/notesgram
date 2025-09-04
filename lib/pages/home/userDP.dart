import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  Map data={};
  DocumentSnapshot? userSnap;
  DocumentSnapshot? currentUserSnap;
  UserUid? userUid;
  bool isFollow=false;
  bool loading=false;

  Future getUserProfile() async {
    userSnap= await DatabaseService(uid: data['userUid']).getUserSnap();
    //getting the current user snap who is logged in
    currentUserSnap= await DatabaseService(uid: userUid?.uid).getUserSnap();
    List<String> followingList=List<String>.from(currentUserSnap?['following']);
    //checking if user is already following that other user
    isFollow=followingList.contains(data['userUid']);
  }
  @override
  Widget build(BuildContext context) {

    //getting the userUid of the user whose profile to be shown
    data=ModalRoute.of(context)!.settings.arguments as Map;

    userUid=Provider.of<UserUid>(context);
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;

    //LoadingScreen can't be disposed by back button.
    return loading ? PopScope(canPop: false, child: LoadingShared()) : FutureBuilder(
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
                      CachedNetworkImageProvider(userSnap?['profilePic']):
                      null,
                      backgroundColor: Colors.purple[100],
                      child: userSnap?['profilePic'] != 'No DP' ?
                        null : const Icon(Icons.person, size: 80),
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
                Text(
                  userSnap?['bio'],
                  style: TextStyle(
                    fontSize: screenWidth*0.045,
                    letterSpacing: 1.0,
                  ),
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
                    //Showing loading screen
                    setState(()=> loading=true);

                    //Creating List from iterable
                    List<String> followingList=List<String>.from(userSnap?['following']);
                    if(!isFollow){
                      //increase the no. of followers of another user
                      //adding the other user uid in the following list
                      await DatabaseService(uid: userUid?.uid ).startFollowing(data['userUid']);
                    }else{
                      //decrease the no. of followers of another user
                      //removing the other userUid in the following
                      await DatabaseService(uid: userUid?.uid ).stopFollowing(data['userUid']);
                    }

                    // re-fetch the latest snapshot and set isFollow again
                    DocumentSnapshot updatedSnap = await DatabaseService(uid: userUid?.uid).getUserSnap();
                    followingList = List<String>.from(updatedSnap['following']);

                    setState(() {
                      isFollow = followingList.contains(data['userUid']);
                      loading=false;
                    });
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
