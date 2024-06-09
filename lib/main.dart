import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/authenticate/otp.dart';
import 'package:notesgram/pages/authenticate/signIn.dart';
import 'package:notesgram/pages/authenticate/signUp.dart';
import 'package:notesgram/pages/home/userDP.dart';
import 'package:notesgram/pages/loading.dart';
import 'package:notesgram/pages/wrapper.dart';
import 'package:notesgram/services/auth.dart';
import 'package:provider/provider.dart';

void main() async  {

  WidgetsFlutterBinding.ensureInitialized();
  // Plugin must be initialized before using
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserUid?>.value(
        value: AuthService().user,
        initialData: null,
        child:  MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context)=> Loading(),
            '/wrapper': (context)=> Wrapper(),
            '/signUp': (context)=> SignUp(),
            '/signIn': (context)=> SignIn(),
            '/userProfile': (context)=> UserProfile(),
          },
        ));
  }
}
