import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/explore/allNotes.dart';


class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60.0),
      // child: AllNotes(),
      child: const AllNotes(),
    );
  }
}
