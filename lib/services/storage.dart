import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServices{

  final String? uid;

  StorageServices({this.uid});

  Future<String> uploadImage(File? file)async {
   UploadTask uploadTask= FirebaseStorage.instance.ref().child("ProfilePictures").child(uid!).putFile(file!);
   // running the uploadTask
   TaskSnapshot taskSnapshot=await uploadTask;

   //getting the url of pic
   String downloadUrl=await taskSnapshot.ref.getDownloadURL();

   return downloadUrl;
  }

  Future<String> uploadPdf(File? file)async {
    //Creating different uid everytime with the help of uuid package.
    UploadTask uploadTask= FirebaseStorage.instance.ref().child(uid!).child(const Uuid().v1()).putFile(file!);
    // running the uploadTask
    TaskSnapshot taskSnapshot=await uploadTask;

    //getting the url of pic
    String downloadUrl=await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }


}