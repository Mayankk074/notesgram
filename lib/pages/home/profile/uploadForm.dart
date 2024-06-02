import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/services/storage.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:provider/provider.dart';

class UploadForm extends StatefulWidget {
  const UploadForm({super.key});

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {

  final _formKey=GlobalKey<FormState>();

  // Form Values
  String? _currentCourse;
  String? _currentSubject;

  String fileName='';
  File? pdf;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserUid>(context);



    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: () async {
                  //picking the notes pdf
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null) {
                    XFile? file = result.files.first.xFile;
                    pdf = File(file.path);
                    //fileName
                    setState(() {
                      fileName = result.files.first.name;
                    });
                  } else {
                    // User canceled the picker
                    print('user cancelled the picker');
                  }
                },
                child: Text('Attach')),
            SizedBox(height: 10.0,),
            Text(fileName),
            SizedBox(height: 10.0,),
            TextFormField(
              decoration: textInputDecoration.copyWith(
                hintText: 'Course/Class Name'
              ),
              validator: (val) => val!.isEmpty ? "Enter Course" : null,
              onChanged: (val) => setState(() => _currentCourse=val),
            ),
            SizedBox(height: 10.0,),
            TextFormField(
              decoration: textInputDecoration.copyWith(
                hintText: 'Subject Name'
              ),
              validator: (val) => val!.isEmpty ? "Enter Course" : null,
              onChanged: (val) => setState(() => _currentSubject=val),
            ),
            SizedBox(height: 30.0,),
            ElevatedButton(
              style: ButtonStyle(
                  fixedSize:
                  WidgetStateProperty.all<Size>(Size(200.0, 60.0)),
                  backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.purple[100]!)
              ),
              onPressed: () async {

                if(_formKey.currentState!.validate()){
                  //uploading the pdf to firebase storage
                  String url =
                  await StorageServices(uid: user.uid).uploadPdf(pdf);

                  //updating the database with pdf url
                  await DatabaseService(uid: user.uid)
                      .updataNotesData(url, fileName, _currentCourse, _currentSubject);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text('Upload'))
          ],
        ),
      ),
    );
  }
}
