import 'package:flutter/material.dart';

class Guidelines extends StatelessWidget {
  const Guidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
📘 Rules for Uploading Notes

1. Upload only original content or content you have rights to share.
2. Do not upload spam, advertisements, or irrelevant material.
3. Notes must be educational and appropriate.
4. Any content violating copyright or offensive material will be removed.
5. Repeated violations may lead to account deletion.

⚠️ By using Notesgram, you agree to follow these rules. 
Violation may result in suspension or permanent account deletion.
            ''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );

  }
}
