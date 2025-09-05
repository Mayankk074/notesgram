import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
    double screenHeight=MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            screenWidth*0.045,
            screenHeight*0.04,
            screenWidth*0.045,
            0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                SizedBox(height: 5,),
                TextFormField(
                  initialValue: currentUsername,
                  validator: (val) => val!.isEmpty ? "Enter username" : null,
                  onChanged: (val) => setState(()=> currentUsername=val),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.alternate_email_outlined),
                  ),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentCollege,
                  validator: (val) => val!.isEmpty ? "Enter college" : null,
                  onChanged: (val) => setState(()=> currentCollege=val),
                  decoration: InputDecoration(
                    labelText: 'College',
                    prefixIcon: const Icon(Icons.school),
                  ),
                ),
                SizedBox(height: screenWidth*0.06,),
                DropdownSearch<String>(
                  items: (f, cs) => courses,
                  selectedItem: currentCourse,
                  popupProps: PopupProps.menu(
                    showSearchBox: true, // Enables searching
                    fit: FlexFit.loose,
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Course',
                      hintText: "Select Course",
                      prefixIcon: Icon(Icons.event_note_outlined)
                    ),
                  ),
                  validator: (val) => val == null ? "Select Course" : null,
                  onChanged: (val) => setState(() => currentCourse = val),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentClass,
                  validator: (val) => val!.isEmpty ? "Enter class" : null,
                  onChanged: (val) => setState(()=> currentClass=val),
                  decoration: InputDecoration(
                      labelText: 'Class',
                      hintText: 'Enter your class',
                      prefixIcon: const Icon(Icons.menu_book)
                  ),
                ),
                SizedBox(height: screenWidth*0.06,),
                TextFormField(
                  initialValue: currentBio,
                  maxLines: 2,
                  maxLength: 50,
                  validator: (val) => val!.isEmpty ? "Enter bio" : null,
                  onChanged: (val) => setState(()=> currentBio=val),
                  decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Enter your bio',
                      prefixIcon: const Icon(Icons.description)
                  ),
                ),
                SizedBox(height: screenWidth*0.06,),
                ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      await DatabaseService(uid: user?.uid).updateUserData(
                        currentUsername!,
                        widget.userDoc?['email'],
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
