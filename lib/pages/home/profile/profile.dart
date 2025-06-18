import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/profile/settingsForm.dart';
import 'package:notesgram/pages/home/profile/uploadForm.dart';
import 'package:notesgram/services/auth.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/services/storage.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    //getting the userData from the stream
    final userDoc = Provider.of<DocumentSnapshot?>(context);
    final user = Provider.of<UserUid>(context);

    void _showUploadPanel(){
      showModalBottomSheet(context: context,
          isScrollControlled: true,
          builder: (context){
        return Padding(
          //for keyboard padding
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: 400,
            child: UploadForm(userDoc: userDoc,),
          ),
        );
      });
    }

    void _showSettingsPanel(){
      showModalBottomSheet(context: context,
          isScrollControlled: true,
          builder: (context){
            return Padding(
              //for keyboard padding
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                // height: 500,
                child: SettingsForm(userDoc: userDoc,),
              ),
            );
          });
    }

    return userDoc == null
        ? const LoadingShared()
        : SafeArea(
          child: Container(
              // alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        TextButton.icon(
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: const Text('Alert!!'),
                                    content: const SingleChildScrollView(
                                      child: Text(
                                        'Do you really want to Sign Out?'
                                      )
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          AuthService().signOut();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                              //
                            },
                            label: const Icon(
                              Icons.logout,
                              size: 30.0,
                              color: Colors.black,
                            ),
                        ),
                        const SizedBox(width: 190.0,),
                        TextButton.icon(
                          onPressed: () => _showSettingsPanel(),
                          label: const Icon(
                            Icons.menu_rounded,
                            size: 30.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      children: [
                        CupertinoButton(
                          onPressed: () async {
                            // picking image from gallery
                            XFile? selectedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (selectedImage != null) {
                              //converting into File
                              File convertedImage = File(selectedImage.path);

                              //uploading image with uid
                              String downloadUrl = await StorageServices(uid: user.uid)
                                  .uploadImage(convertedImage);
                              //updating the profilePic url
                              DatabaseService(uid: user.uid).updateUserData(
                                userDoc['username'],
                                userDoc['email'],
                                userDoc['password'],
                                downloadUrl,
                                userDoc['college'],
                                userDoc['course'],
                                userDoc['class'],
                                userDoc['bio'],
                                userDoc['followers'],
                                List<String>.from(userDoc['following']),
                                userDoc['notesUploaded'],
                                HashSet<String>.from(userDoc['liked']),
                              );

                              log("image selected!");
                            } else {
                              log("image not selected");
                            }
                          },
                          padding: EdgeInsets.zero,
                          child: CircleAvatar(
                            radius: 35.0,
                            // Getting the profile pic from the database
                            //if there is no dp then dont show image
                            backgroundImage: userDoc['profilePic'] != 'No DP'
                                ? NetworkImage(userDoc['profilePic'])
                                : null,
                            backgroundColor: Colors.purple[100],
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userDoc['username'],
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                userDoc['college'],
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                '${userDoc['course']} ${userDoc['class']}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          userDoc['bio'],
                          style: const TextStyle(
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0,),
                    const Divider(),
                    Row(
                      children: [
                        const SizedBox(width: 30,),
                        Text(
                          '${userDoc['followers']}',
                          style: const TextStyle(
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(width: 80,),
                        const Text(
                          "Followers",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 1
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0,),
                    Row(
                      children: [
                        const SizedBox(width: 30,),
                        Text(
                          '${userDoc['following'].length}',
                          style: const TextStyle(
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(width: 80,),
                        const Text(
                          "Following",
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 1
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30.0,),
                    Row(
                      children: [
                        const SizedBox(width: 30,),
                        Text(
                          '${userDoc['notesUploaded']}',
                          style: const TextStyle(
                            fontSize: 40.0,
                          ),
                        ),
                        const SizedBox(width: 80,),
                        const Text(
                          "PDFs Uploaded",
                          style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 1
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 50,),
                    ElevatedButton(
                      onPressed:() => _showUploadPanel(),
                      style: buttonStyleSignUp,
                      child: const Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        );
  }
}
