import 'package:flutter/material.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/theme/theme.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3F51B5),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/loginBG.webp'),
              fit: BoxFit.cover,
            )
          ),
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pushNamed(context, '/signUp');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0,),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/signIn');
                  },
                  style: buttonStyleSignIn,
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16.0,
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
