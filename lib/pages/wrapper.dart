import 'package:flutter/material.dart';
import 'package:notesgram/models/userUid.dart';
import 'package:notesgram/pages/authenticate/login.dart';
import 'package:notesgram/pages/home/home.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //listening for user change
    final user=Provider.of<UserUid?>(context);

    // print(user?.uid);

    if(user==null){
      return Login();
    }else{
      return const Home();
    }
  }
}
