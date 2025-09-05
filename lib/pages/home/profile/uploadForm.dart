import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/services/storage.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:provider/provider.dart';

class UploadForm extends StatefulWidget {
  UploadForm({super.key, this.userDoc});
  DocumentSnapshot? userDoc;

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {

  final _formKey=GlobalKey<FormState>();

  // Form Values
  String? _currentCourse;
  String? _currentSubject;
  String? _currentDescription;

  String fileName='File size should not exceed 2 MB';
  File? pdf;

  final InAppReview inAppReview = InAppReview.instance;

  Future<void> showReviewPopup() async {
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      // fallback: open Play Store
      inAppReview.openStoreListing();
    }
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserUid>(context);

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                //picking the notes pdf
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  int size=result.files.first.size;
                  //Comparing the size to 2 MB
                  if(size < 2048000){
                    XFile? file = result.files.first.xFile;
                    pdf = File(file.path);
                    //fileName
                    setState(() {
                      //Removing the .pdf from title and Assigning to fileName
                      String temp=result.files.first.name;
                      temp=temp.replaceAll(".pdf", "");
                      fileName = temp;
                    });
                  }
                  else{
                    setState(() {
                      //Clearing the memory
                      pdf=null;
                      fileName='File size should not exceed 2 MB';
                    });
                  }
                }
              },
              style: buttonStyleSignIn,
              child: const Text(
                'Attach',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),

            ),
            const SizedBox(height: 10.0,),
            Text(fileName),
            const SizedBox(height: 10.0,),
            Expanded(
              child: // Course Dropdown
              // Course Searchable Dropdown
              DropdownSearch<String>(
                items: (f, cs) => courses,
                selectedItem: _currentCourse,
                popupProps: PopupProps.menu(
                  showSearchBox: true, // Enables searching
                  fit: FlexFit.loose,
                ),
                decoratorProps: DropDownDecoratorProps(
                  decoration: textInputDecoration.copyWith(
                    hintText: "Select Course",
                  ),
                ),
                validator: (val) => val == null ? "Select Course" : null,
                onChanged: (val) => setState(() => _currentCourse = val),
              ),
            ),
            const SizedBox(height: 10.0,),
            Expanded(
              child: // Subject Dropdown
              // Course Searchable Dropdown
              DropdownSearch<String>(
                items: (f, cs) => subjects,
                selectedItem: _currentSubject,
                popupProps: PopupProps.menu(
                  showSearchBox: true, // Enables searching
                  fit: FlexFit.loose,
                ),
                decoratorProps: DropDownDecoratorProps(
                  decoration: textInputDecoration.copyWith(
                    hintText: "Select Subject",
                  ),
                ),
                validator: (val) => val == null ? "Select Subject" : null,
                onChanged: (val) => setState(() => _currentSubject = val),
              ),
            ),
            const SizedBox(height: 10.0,),
            Expanded(
              child: TextFormField(
                decoration: textInputDecoration.copyWith(
                    hintText: 'Description'
                ),
                validator: (val) => val!.isEmpty ? "Enter Description" : null,
                onChanged: (val) => setState(() => _currentDescription=val),
              ),
            ),
            const SizedBox(height: 30.0,),
            ElevatedButton(
              style: buttonStyleSignUp,
              onPressed: () async {

                if(_formKey.currentState!.validate() && pdf != null){
                  //adding the Note in DB as a subCollection document asynchronously
                  DatabaseService(uid: user.uid)
                        .addNote(file: pdf, course: _currentCourse,description: _currentDescription,likes: 0, fileName: fileName, subject: _currentSubject);

                  if (context.mounted) Navigator.pop(context);
                  const snackBar = SnackBar(
                    content: Text('Yay! PDF has been uploading!'),
                    duration: Duration(seconds: 1),
                  );
                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  //Open Review panel for play store
                  await showReviewPopup();
                }
              },
              child: const Text(
                'Upload',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ))
          ],
        ),
      ),
    );
  }
}
