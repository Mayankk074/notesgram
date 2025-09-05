import 'package:flutter/material.dart';

class Earn extends StatelessWidget {
  const Earn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Earn'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              """
In the future, Notesgram will allow you to turn your study material into a source of income. 
By sharing your notes with others, you can help students and professionals while also earning rewards. 
You will be able to decide how your notes are shared, either freely or at a price that you set.
              """,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Text(
              "Ways you can monetize your notes:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text("• Earn money whenever someone purchases your premium notes."),
            SizedBox(height: 5),
            Text(
                "• Gain followers and build credibility to increase downloads."),
            SizedBox(height: 5),
            Text("• Participate in reward programs for top contributors."),
            SizedBox(height: 5),
            Text(
                "• Offer subscription bundles for students who want access to all your notes."),
            SizedBox(height: 5),
            Text("• Get featured in the community to boost your visibility."),
          ]),
        ));
  }
}
