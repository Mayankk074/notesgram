import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/explore/allNotes.dart';
import 'package:provider/provider.dart';

import '../../../models/userUid.dart';


class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  @override
  Widget build(BuildContext context) {
    final currUser=Provider.of<UserUid>(context);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 20.0),
      child: AllNotes(currUserUid: currUser,),
    );
  }
}
