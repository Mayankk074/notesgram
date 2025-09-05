import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/services/auth.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';

import '../../services/database.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final _formKey=GlobalKey<FormState>();
  final AuthService _auth=AuthService();

  final CollectionReference _userCollection=FirebaseFirestore.instance
      .collection('users');

  //loading screen
  bool loading=false;

  //error
  String error='';

  //textfields values
  String email='';
  String pass='';

  @override
  Widget build(BuildContext context) {
    return loading? PopScope(canPop: false, child: LoadingShared()): Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(Duration(milliseconds: 300));
              if(context.mounted) Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)
        ),
        backgroundColor: Colors.purple[50],
      ),
      backgroundColor: Colors.purple[50],
      body: Container(
        padding:  EdgeInsets.only(
          top: MediaQuery.of(context).size.height*0.1,
          left: 20.0,
          right: 20.0,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello!',
                      style: TextStyle(
                        fontSize:80.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize:20.0,
                  ),
                ),
                const SizedBox(height: 50.0,),
                TextFormField(
                  validator: (val) => val!.isEmpty ? 'Enter a email': null,
                  onChanged: (val) => setState(()=> email=val ),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.alternate_email_outlined
                      )),
                ),
                const SizedBox(height: 15.0,),
                TextFormField(
                  validator: (val) => val!.length < 6 ? 'Enter valid password': null,
                  onChanged: (val) => setState(()=> pass=val ),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.password
                      )
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 35.0,),
                ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      setState(()=> loading=true);
                      dynamic result=await _auth.signIn(email, pass);
                      if(result==null){
                        setState(() {
                          error='There is an error';
                          loading=false;
                        });
                  
                      }else{
                        if(context.mounted) Navigator.of(context).pop();
                      }
                    }
                  },
                  style: buttonStyleSignIn,
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0,),
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
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
                    setState(()=> loading=true);
                    try{
                      dynamic result= await _auth.signInWithGoogle();
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
                              'Enter course','Enter class','Enter bio',0,[],0,HashSet<String>());
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    }catch(e){
                      setState(()=> loading=false);
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
