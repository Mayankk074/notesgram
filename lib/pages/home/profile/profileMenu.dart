import 'package:flutter/material.dart';
import 'package:notesgram/pages/home/profile/settingsForm.dart';

import '../../../services/auth.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    Map data=ModalRoute.of(context)?.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Edit profile'),
            onTap: (){
              //Building the Route Page and sending userDoc so that SettingsForm will initialize once via initState
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsForm(userDoc: data['userDoc'])));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            onTap: (){
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer_outlined),
            title: const Text('FAQs'),
            onTap: (){
              Navigator.pushNamed(context, '/faq');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: const Text('Alert!!'),
                      content: const SingleChildScrollView(
                          child: Text(
                              'Do you really want to Sign Out?'
                          )
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await AuthService().signOut();
                            if(context.mounted) Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
          )
        ],
      )
    );
  }
}
