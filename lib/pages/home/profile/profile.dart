import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/home/profile/uploadForm.dart';
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

    void showUploadPanel() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SafeArea(
              child: Padding(
                //for keyboard padding
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(
                  height: 400,
                  child: UploadForm(
                    userDoc: userDoc,
                  ),
                ),
              ),
            );
          });
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return userDoc == null
        ? const LoadingShared()
        : Container(
            padding: EdgeInsets.only(left: screenWidth * 0.045),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          //Sending the userDoc for details
                          await Navigator.pushNamed(context, '/profileMenu',
                              arguments: {'userDoc': userDoc});
                          //updating UI because there might be edit in details
                          setState(() {});
                        },
                        label: Icon(
                          Icons.settings_outlined,
                          size: screenWidth * 0.08,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
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
                            String downloadUrl =
                                await StorageServices(uid: user.uid)
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
                          radius: screenWidth * 0.12,
                          // Getting the profile pic from the database
                          //if there is no dp then dont show image
                          backgroundImage: userDoc['profilePic'] != 'No DP'
                              ? NetworkImage(userDoc['profilePic'])
                              : null,
                          backgroundColor: Colors.purple[100],
                          //showing person Icon if there is no DP
                          child: userDoc['profilePic'] != 'No DP'
                              ? null
                              : const Icon(Icons.person, size: 80),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.07,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDoc['username'],
                              style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userDoc['college'],
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              '${userDoc['course']} - ${userDoc['class']}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    userDoc['bio'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/savedNotes',
                          arguments: {'userDoc': userDoc});
                    },
                    style: buttonStyleSignUp,
                    child: Text(
                      'Saved Notes',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const Divider(),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.05,
                      ),
                      Text(
                        '${userDoc['followers']}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.1,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.2,
                      ),
                      Text(
                        "Followers",
                        style: TextStyle(
                            fontSize: screenWidth * 0.065, letterSpacing: 1),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.05,
                      ),
                      Text(
                        '${userDoc['following'].length}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.1,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.2,
                      ),
                      Text(
                        "Following",
                        style: TextStyle(
                            fontSize: screenWidth * 0.065, letterSpacing: 1),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.05,
                      ),
                      Text(
                        '${userDoc['notesUploaded']}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.1,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.2,
                      ),
                      Flexible(
                        child: Text(
                          "PDFs Uploaded",
                          style: TextStyle(
                              fontSize: screenWidth * 0.065, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  SizedBox(
                    height: screenHeight * 0.10,
                  ),
                  ElevatedButton(
                    onPressed: () => showUploadPanel(),
                    style: buttonStyleSignIn,
                    child: Text(
                      'Upload',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
