import 'package:flutter/material.dart';

class Faq extends StatelessWidget {
  const Faq({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''Frequently Asked Questions (FAQs)

1. What is NotesGram?
NotesGram is an app that allows users to upload, store, and access notes in PDF format. It helps students and professionals manage their study materials efficiently.

2. Is NotesGram free to use?
Yes, NotesGram is free to use. Some features may require internet access.

3. What types of files can I upload?
Currently, NotesGram supports PDF files only. Support for other formats may be added in future updates.

4. Are my uploaded notes private?
Yes, your notes are private by default. We do not share your content with others without your permission.

5. Can I delete my notes or account?
Absolutely. You can delete any note you uploaded, and you can also delete your account from the settings section.

6. Will NotesGram show ads?
Currently, NotesGram is ad-free. If we introduce ads in the future, they will be minimal and non-intrusive.

7. Does NotesGram work offline?
You can view downloaded notes offline. However, uploading and syncing require an internet connection.
''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );

  }
}
