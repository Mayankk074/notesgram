import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/services/auth.dart';
import 'package:notesgram/services/database.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final _formKey=GlobalKey<FormState>();

  final CollectionReference _userCollection=FirebaseFirestore.instance
      .collection('users');

  // TextFormField Values
  String? username;
  String? email;
  String? password;

  //loading screen
  bool loading=false;

  //error value
  String error='';

  final AuthService _auth=AuthService();


  @override
  Widget build(BuildContext context) {
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;

    return loading? PopScope(canPop: false, child: LoadingShared()): GestureDetector(
      //When clicking outside the keyboard unfocus keyboard.
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(Duration(milliseconds: 300));
              if(context.mounted) Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body:
        Container(
          padding: EdgeInsets.fromLTRB(screenWidth*0.05,screenHeight*0.04,screenWidth*0.05,0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Just a few quick things to get started:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:MediaQuery.of(context).size.width * 0.05,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  TextFormField(
                    validator: (val) => val!.isEmpty ? 'Enter a username': null,
                    onChanged: (val) => setState(()=> username=val ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: const Icon(Icons.alternate_email_outlined),
                    )
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  TextFormField(
                    validator: (val) => val!.isEmpty ? 'Enter a email': null,
                    onChanged: (val) => setState(()=> email=val ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your Email',
                      prefixIcon: const Icon(Icons.email)
                    )
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  TextFormField(
                    validator: (val) => val!.length < 6 ? 'Enter a password': null,
                    onChanged: (val) => setState(()=> password=val ),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.password)
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  TextFormField(
                    validator: (val) => val! != password ? 'Enter same password': null,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Enter your password again',
                      prefixIcon: const Icon(Icons.password)
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    onPressed: () async {
                      //Unfocus keyboard before navigating
                      FocusManager.instance.primaryFocus?.unfocus();

                      if(_formKey.currentState!.validate()){
                        await Navigator.pushNamed(context, '/details', arguments: {
                          'email': email,
                          'password': password,
                          'username': username
                        });
                      }
                    },
                    child: const Text('Next'),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(error,style: const TextStyle(
                    color: Colors.red,
                  ),),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  //Google SignIn
                  CupertinoButton(
                    onPressed: () async {
                      setState(() => loading =true);
                      try{
                        UserCredential? result= await _auth.signInWithGoogle();
                        if(result==null){
                          setState(() {
                            error='There is an error';
                            loading=false;
                          });
                        }else{
                          User? user = result.user;
                          bool flag=false;
                          //checking if user is already present
                          QuerySnapshot snap=await _userCollection.get();
                          List<DocumentSnapshot> listOfDocs=snap.docs;
                          for(DocumentSnapshot snap in listOfDocs){
                            if(snap.id == user?.uid){
                              flag=true;
                              break;
                            }
                          }
                          if(!flag){
                            //creating new DB if user is not present
                            String? gMail=user?.email;
                            String? name=user?.displayName;
                            String? photoUrl=user?.photoURL;
                            await DatabaseService(uid: user?.uid).updateUserData(name!, gMail!, photoUrl,'Enter college name',
                                'Enter course','Enter class','Enter bio',0,[],0, HashSet<String>());
                          }
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      }
                      catch(e){
                        if(kDebugMode) print(e);
                        setState(() => loading = false);
                      }
      
                    },
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: const AssetImage(
                          'assets/googleLogo.png'
                      ),
                      backgroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
