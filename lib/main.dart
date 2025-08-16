import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/authenticate/signIn.dart';
import 'package:notesgram/pages/authenticate/signUp.dart';
import 'package:notesgram/pages/home/note_viewer.dart';
import 'package:notesgram/pages/home/otherUserFiles.dart';
import 'package:notesgram/pages/home/profile/faq.dart';
import 'package:notesgram/pages/home/profile/privacy.dart';
import 'package:notesgram/pages/home/profile/profileMenu.dart';
import 'package:notesgram/pages/home/profile/savedNotes.dart';
import 'package:notesgram/pages/home/userDP.dart';
import 'package:notesgram/pages/loading.dart';
import 'package:notesgram/pages/wrapper.dart';
import 'package:notesgram/services/auth.dart';
import 'package:notesgram/shared/loadingShared.dart';
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
            '/': (context)=> const Loading(),
            '/wrapper': (context)=> const Wrapper(),
            '/signUp': (context)=> const SignUp(),
            '/signIn': (context)=> const SignIn(),
            '/userProfile': (context)=> const UserProfile(),
            '/otherUserFiles': (context)=> OtherUserFiles(),
            '/loadingShared': (context)=> const LoadingShared(),
            '/singleNote': (context)=> const NoteViewer(),
            '/profileMenu': (context) => const Menu(),
            '/privacy': (context) => const Privacy(),
            '/faq': (context) => const Faq(),
            '/savedNotes': (context) => const SavedNotes()
          },
        ));
  }
}
