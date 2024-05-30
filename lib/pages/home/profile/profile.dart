import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/services/storage.dart';
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

    return userDoc == null
        ? const LoadingShared()
        : Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                        onPressed: (){},
                        label: Icon(
                          Icons.logout,
                          size: 30.0,
                        ),
                    ),
                    SizedBox(width: 190.0,),
                    TextButton.icon(
                      onPressed: (){},
                      label: Icon(
                        Icons.settings,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
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
                      DatabaseService(uid: user.uid).updataUserData(
                          userDoc['username'],
                          userDoc['email'],
                          userDoc['password'],
                          downloadUrl);

                      log("image selected!");
                    } else {
                      log("image not selected");
                    }
                  },
                  padding: EdgeInsets.zero,
                  child: CircleAvatar(
                    radius: 70.0,
                    // Getting the profile pic from the database
                    backgroundImage: userDoc['profilePic'] != null
                        ? NetworkImage(userDoc['profilePic'])
                        : null,
                    backgroundColor: Colors.redAccent,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  userDoc?['username'],
                  style: const TextStyle(
                    fontSize: 25.0,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  userDoc?['email'],
                  style: const TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 20.0,),
                const Row(
                  children: [
                    SizedBox(width: 70,),
                    Text(
                        "0",
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                    SizedBox(width: 140,),
                    Text(
                        "0",
                      style: TextStyle(
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
                SizedBox(height: 20.0,),
                Text(
                  "0",
                  style: TextStyle(
                    fontSize: 40.0,
                  ),
                ),
                Text(
                  "PDFs Uploaded",
                ),
                SizedBox(height: 50,),
                ElevatedButton(
                  onPressed: () async {
                    //picking the notes pdf
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null) {
                      XFile? file = result.files.first.xFile;
                      File pdf = File(file.path);
                      //fileName
                      String fileName = result.files.first.name;

                      //uploading the pdf to firebase storage
                      String url =
                          await StorageServices(uid: user.uid).uploadPdf(pdf);

                      //updating the database with pdf url
                      await DatabaseService(uid: user.uid).updataNotesData(url, fileName);
                    } else {
                      // User canceled the picker
                      print('user cancelled the picker');
                    }
                  },
                  child: Text('Upload'),
                  style: ButtonStyle(
                      fixedSize:
                          WidgetStateProperty.all<Size>(Size(300.0, 60.0)),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.purple[100]!)),
                ),
              ],
            ),
          );
  }
}
