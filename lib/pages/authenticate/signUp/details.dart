import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notesgram/shared/constants.dart';
import 'package:notesgram/shared/loadingShared.dart';

import '../../../services/auth.dart';
import '../../../services/database.dart';
import '../../../services/storage.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final _formKey=GlobalKey<FormState>();
  File? _currentProfileImage;
  String? _currentCollege;
  String? _currentCourse;
  String? _currentClass;
  String? _currentBio;
  String error='';

  bool loading=false;

  final AuthService _auth=AuthService();

  @override
  Widget build(BuildContext context) {
    double screenWidth=MediaQuery.of(context).size.width;
    double screenHeight=MediaQuery.of(context).size.height;

    final data=ModalRoute.of(context)?.settings.arguments as Map;

    //LoadingScreen can't be disposed by back button.
    return loading ? PopScope(canPop: false, child: LoadingShared()) : Scaffold(
      appBar: AppBar(
        title: Text('Fill Details'),
        // backgroundColor: Colors.purple[50],
      ),
      // backgroundColor: Colors.purple[50],
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth*0.05,screenHeight*0.04,screenWidth*0.05,0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      onPressed: () async {
                        // picking image from gallery
                        XFile? selectedImage = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
        
                        if (selectedImage != null) {
                          int size=await selectedImage.length();
                          if(size < 1048000){
                            //converting into File
                            setState(() {
                              _currentProfileImage = File(selectedImage.path);
                              error='';
                            });
                          }
                          else{
                            setState(() {
                              _currentProfileImage=null;
                              error='Selected image is large';
                            });
                          }
                          log("image selected!");
                        } else {
                          log("image not selected");
                        }
                      },
                      padding: EdgeInsets.zero,
                      child: CircleAvatar(
                        radius: screenWidth * 0.2,
                        // Getting the profile pic from the database
                        //if there is no dp then don't show image
                        backgroundImage: _currentProfileImage != null
                            ? FileImage(_currentProfileImage!)
                            : null,
                        backgroundColor: Color(0xFF3F51B5),
                        //showing person Icon if there is no DP
                        child: _currentProfileImage != null
                            ? null
                            : const Icon(Icons.person, color: Colors.white, size: 140),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05,),
                TextFormField(
                  validator: (val) => val!.length > 15 ? null : 'Enter valid college name',
                  onChanged: (val) => setState(() => _currentCollege = val),
                  decoration: InputDecoration(
                      labelText: 'College name',
                      hintText: 'Enter your college name',
                      prefixIcon: const Icon(Icons.school)
                  ),
                ),
                SizedBox(height: screenHeight * 0.03,),
                DropdownSearch<String>(
                  items: (f, cs) => courses,
                  selectedItem: _currentCourse,
                  popupProps: PopupProps.menu(
                    showSearchBox: true, // Enables searching
                    fit: FlexFit.loose,
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Course',
                      hintText: "Select Course",
                      prefixIcon: Icon(Icons.event_note_outlined)
                    ),
                  ),
                  validator: (val) => val == null ? "Select Course" : null,
                  onChanged: (val) => setState(() => _currentCourse = val),
                ),
                SizedBox(height: screenHeight * 0.03,),
                TextFormField(
                  validator: (val) => val!.isNotEmpty ? null : 'Enter valid class',
                  onChanged: (val) => setState(() => _currentClass = val),
                  decoration: InputDecoration(
                      labelText: 'Class',
                      hintText: 'Enter your class',
                      prefixIcon: const Icon(Icons.menu_book)
                  ),
                ),
                SizedBox(height: screenHeight * 0.03,),
                TextFormField(
                  validator: (val) => val!.isNotEmpty ? null : 'Enter valid bio',
                  onChanged: (val) => setState(() => _currentBio = val),
                  decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Enter your bio',
                      prefixIcon: const Icon(Icons.description)
                  ),
                  maxLines: 4,
                  maxLength: 100,
                ),
                SizedBox(height: screenHeight * 0.03,),
                ElevatedButton(
                  onPressed: ()async{
                    if(_formKey.currentState!.validate()){
                      //showing loading screen
                      setState(()=> loading=true);

                      dynamic result=await _auth.signUpWithEmailAndPassword(data['email'], data['password']);
                      if(result==null){
                        setState(() {
                          error='There is an error';
                          loading=false;
                        });
                      }
                      else{
                        String imageUrl = 'No DP';
                        if(_currentProfileImage != null){
                          //uploading image with uid
                           imageUrl = await StorageServices(uid: result.uid).uploadImage(_currentProfileImage);
                        }

                        await DatabaseService(uid: result.uid).updateUserData(data['username'], data['email'], imageUrl,
                            _currentCollege!, _currentCourse!, _currentClass!, _currentBio!, 0, [], 0, HashSet<String>());
                        if (context.mounted) Navigator.of(context).pop();
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    }
                  },
                  style: buttonStyleSignIn,
                  child: Text('Create account')
                ),
                SizedBox(height: screenHeight * 0.01,),
                Text(error,style: const TextStyle(
                  color: Colors.red,
                ),),
              ],
            ),
          )
        ),
      )
    );
  }
}
