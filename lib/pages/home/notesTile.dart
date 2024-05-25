import 'package:flutter/material.dart';

class NotesTile extends StatelessWidget {
  const NotesTile({super.key, this.pdf, this.name});

  final String? pdf;
  final String? name;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 15.0,
          ),
          title: Text(name!),
        ),
      ),
    );
  }
}
