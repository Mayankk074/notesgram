import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/explore/allNotes.dart';
import 'package:notesgram/pages/home/upload.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:provider/provider.dart';

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
      padding: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 0),
      child: Column(
        children: [
          TextField(
            decoration: textInputDecoration.copyWith(
              labelText: "Search",
            ),
          ),
          // ElevatedButton(
          //   onPressed: ()async {
          //     List<DocumentSnapshot> list= snapshot.docs;
          //     print(list[0]['names']);
          //   } ,
          //   child: Text("Press"))
          Expanded(
            child: AllNotes(),
          ),
        ],
      ),
    );
  }
}
