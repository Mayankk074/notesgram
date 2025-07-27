import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  SettingsForm({super.key, this.userDoc});

  DocumentSnapshot? userDoc;

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  String? currentUsername;
  String? currentCollege;
  String? currentCourse;
  String? currentClass;
  String? currentBio;

  final _formKey=GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    //getting the current details
    currentUsername=widget.userDoc?['username'];
    currentCollege=widget.userDoc?['college'];
    currentCourse=widget.userDoc?['course'];
    currentClass=widget.userDoc?['class'];
    currentBio=widget.userDoc?['bio'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user=Provider.of<UserUid?>(context);
    double screenWidth=MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            screenWidth*0.045,
            screenWidth*0.1,
            screenWidth*0.045,
            screenWidth*0.065),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: currentUsername,
                  decoration: textInputDecoration,
                  validator: (val) => val!.isEmpty ? "Enter username" : null,
                  onChanged: (val) => setState(()=> currentUsername=val),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentCollege,
                  decoration: textInputDecoration,
                  validator: (val) => val!.isEmpty ? "Enter college" : null,
                  onChanged: (val) => setState(()=> currentCollege=val),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentCourse,
                  decoration: textInputDecoration,
                  validator: (val) => val!.isEmpty ? "Enter course" : null,
                  onChanged: (val) => setState(()=> currentCourse=val),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentClass,
                  decoration: textInputDecoration,
                  validator: (val) => val!.isEmpty ? "Enter class" : null,
                  onChanged: (val) => setState(()=> currentClass=val),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentBio,
                  decoration: textInputDecoration,
                  maxLines: 2,
                  maxLength: 50,
                  validator: (val) => val!.isEmpty ? "Enter bio" : null,
                  onChanged: (val) => setState(()=> currentBio=val),
                ),
                SizedBox(height: screenWidth*0.06,),
                ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      await DatabaseService(uid: user?.uid).updateUserData(
                        currentUsername!,
                        widget.userDoc?['email'],
                        widget.userDoc?['password'],
                        widget.userDoc?['profilePic'],
                        currentCollege!,
                        currentCourse!,
                        currentClass!,
                        currentBio!,
                        widget.userDoc?['followers'],
                        List<String>.from(widget.userDoc?['following']),
                        widget.userDoc?['notesUploaded'],
                        HashSet<String>.from(widget.userDoc?['liked']),
                      );
                      if(!context.mounted) return;
                      //removing screens so it will fetch new data
                      Navigator.pop(context);
                      Navigator.pop(context);
                      const snackBar = SnackBar(
                        content: Text('Yay! User Data has been updated!'),
                      );
                      // Find the ScaffoldMessenger in the widget tree
                      // and use it to show a SnackBar.
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  style: buttonStyleSignUp,
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: screenWidth*0.055,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
