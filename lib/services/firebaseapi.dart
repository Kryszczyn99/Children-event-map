import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    final ref = FirebaseStorage.instance.ref(destination);
    return ref.putFile(file);
  }

  static Future<dynamic> loadImage(BuildContext context, String image) async {
    return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
  }

  static Future<dynamic> loadImageWithoutContext(String image) async {
    return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
  }

  static Future<dynamic> deleteFolder(String destination) async {
    final ref = FirebaseStorage.instance.ref(destination);
    final list = await ref.listAll();
    for (var element in list.items) {
      FirebaseApi.deleteFile(element.fullPath);
    }
    return await ref.listAll();
  }

  static Future<dynamic> deleteFile(String destination) {
    final ref = FirebaseStorage.instance.ref(destination);
    return ref.delete();
  }
}
