import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          //Triple quotes for multiple lines
          '''Last Updated: July 27, 2025

NotesGram ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.

1. Information We Collect
- Personal Information: When you create an account, we may collect your email address and other optional profile details.
- Uploaded Content: We collect and store the PDF notes and other files you choose to upload.
- Usage Data: We may collect anonymous data about how you interact with the app to improve our services.

2. How We Use Your Information
- To provide and maintain the NotesGram service.
- To improve user experience and app performance.
- To respond to user inquiries and support requests.

3. Data Sharing
- We do not sell, trade, or rent your personal information to others.
- We may share your data with service providers who help us operate the app, under strict confidentiality agreements.

4. Data Security
- We implement industry-standard security measures to protect your data from unauthorized access.

5. Your Choices
- You can update or delete your account and uploaded content at any time.
- You may opt out of certain data collection features through your device settings.

6. Changes to This Policy
- We may update this policy from time to time. You will be notified of significant changes.

By using NotesGram, you agree to the terms outlined in this Privacy Policy.
''',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );

  }
}
