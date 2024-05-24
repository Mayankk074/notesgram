import 'package:flutter/material.dart';
import 'package:notesgram/services/auth.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final _formKey=GlobalKey<FormState>();
  final AuthService _auth=AuthService();

  //loading screen
  bool loading=false;

  //error
  String error='';

  //textfields values
  String email='';
  String pass='';

  @override
  Widget build(BuildContext context) {
    return loading? const LoadingShared(): Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        backgroundColor: Colors.purple[100],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 2000.0,
          padding: const EdgeInsets.fromLTRB(20.0, 200.0, 20.0, 0),
          color: Colors.purple[50],
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize:40.0,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
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
                  child: const Text('Sign In'),
                ),
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
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
