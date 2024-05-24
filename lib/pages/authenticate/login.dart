import 'package:flutter/material.dart';
import 'package:notesgram/services/auth.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final AuthService _auth=AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/NoteBG.jpg'),
              fit: BoxFit.cover,
            )
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 530.0, 0.0, 0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pushNamed(context, '/signUp');
                      },
                      style: ButtonStyle(
                        fixedSize: WidgetStateProperty.all<Size>(Size.fromWidth(300.0)),
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.purpleAccent[200]!),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0,),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/signIn');
                    // print(result.uid);
                  },
                  style: ButtonStyle(
                      fixedSize: WidgetStateProperty.all<Size>(Size.fromWidth(300.0)),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.purpleAccent[200]!),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
