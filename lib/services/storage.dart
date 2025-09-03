import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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

  Future<Map<String, String>> uploadPdf(File? file)async {
    // generate unique path
    String fileId = const Uuid().v1();
    String filePath = "notes/$uid/$fileId.pdf";

    //Upload
    UploadTask uploadTask= FirebaseStorage.instance.ref(filePath).putFile(file!);
    // running the uploadTask
    TaskSnapshot taskSnapshot=await uploadTask;

    //getting the url of pic
    String downloadUrl=await taskSnapshot.ref.getDownloadURL();

    // return both path and url
    return {
      "url": downloadUrl,
      "path": filePath,
    };
  }

  Future<void> deletePdf(String filePath) async{
    try {
      // Delete file from Storage
      await FirebaseStorage.instance.ref(filePath).delete();

    } catch (e) {
      if (kDebugMode) {
        print("Error deleting PDF from storage: $e");
      }
    }
  }


}