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


  final _formKey=GlobalKey<FormState>();
  String? _currentUsername;
  @override
  Widget build(BuildContext context) {

    final user=Provider.of<UserUid?>(context);


    return Padding(
      padding: EdgeInsets.fromLTRB(8.0,40,8,0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.userDoc?['username'],
              decoration: textInputDecoration,
              validator: (val) => val!.isEmpty ? "Enter username" : null,
              onChanged: (val) => setState(()=> _currentUsername=val),
            ),
            SizedBox(height: 60.0,),
            ElevatedButton(
              onPressed: () async {
                if(_formKey.currentState!.validate()){
                  await DatabaseService(uid: user?.uid).updataUserData(
                    _currentUsername!,
                    widget.userDoc?['email'],
                    widget.userDoc?['password'],
                    widget.userDoc?['profilePic'],
                    widget.userDoc?['followers'],
                    List<String>.from(widget.userDoc?['following']),
                    widget.userDoc?['notesUploaded'],
                  );
                  if(!context.mounted) return;
                  Navigator.pop(context);
                  const snackBar = SnackBar(
                    content: Text('Yay! User Data has been updated!'),
                  );
                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Text('Update'),
              style: ButtonStyle(
                  fixedSize:
                  WidgetStateProperty.all<Size>(Size(200.0, 60.0)),
                  backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.purple[100]!)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
