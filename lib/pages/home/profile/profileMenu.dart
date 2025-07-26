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
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Edit profile'),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsForm(userDoc: data['userDoc'])));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
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
