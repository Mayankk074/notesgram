import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
    return loading? const LoadingShared(): Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[50],
      ),
      backgroundColor: Colors.purple[50],
      body:
      Container(
        padding: const EdgeInsets.fromLTRB(20.0,30.0,20.0,0.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 33.0,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15.0,),
                const Text(
                  'Just a few quick things to get started:',
                  style: TextStyle(
                    fontSize:20.0,
                  ),
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Enter a username': null,
                  onChanged: (val) => setState(()=> username=val ),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: const Icon(Icons.alternate_email_outlined
                      )),
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Enter a email': null,
                  onChanged: (val) => setState(()=> email=val ),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      hintText: 'Enter your Email',
                      prefixIcon: const Icon(Icons.email
                      )),
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  validator: (val) => val!.length < 6 ? 'Enter a password': null,
                  onChanged: (val) => setState(()=> password=val ),
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.password
                                )
                              ),
                  obscureText: true,
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  validator: (val) => val! != password ? 'Enter same password': null,
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Confirm Password',
                      hintText: 'Enter your password again',
                      prefixIcon: const Icon(Icons.password
                      )),
                ),
                const SizedBox(height: 40.0,),
                ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      setState(()=> loading=true);
                      dynamic result=await _auth.signUpWithEmailAndPassword(email!, password!);
                      if(result==null){
                        setState(() {
                          error='There is an error';
                          loading=false;
                        });
                      }
                      else{
                        await DatabaseService(uid: result.uid).updateUserData(username!, email!, password!,'No DP','Enter college name',
                            'Enter course','Enter class','Enter bio',0,[],0,HashSet<String>());
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    }
                  },
                  style: buttonStyleSignUp,
                  child: const Text('Create account'),
                ),
                const SizedBox(height: 10.0,),
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
                        await DatabaseService(uid: user?.uid).updateUserData(name!, gMail!, "",photoUrl,'Enter college name',
                            'Enter course','Enter class','Enter bio',0,[],0, HashSet<String>());
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: CircleAvatar(
                    radius: 40.0,
                    backgroundImage: const AssetImage(
                        'assets/googleLogo.png'
                    ),
                    backgroundColor: Colors.purple[50],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
