import 'dart:io';

import 'package:children_event_map/services/database.dart';
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

  static Future<dynamic> getListOfImages(String destination) async {
    final ref = FirebaseStorage.instance.ref(destination);
    final list = await ref.listAll();
    List<String> paths = [];
    for (var element in list.items) {
      paths.add(element.fullPath.toString());
    }
    return paths;
  }

  static Future<dynamic> deleteEventFolder(String destination) async {
    var result =
        await DatabaseService(uid: '').getAllPostListByEventId(destination);
    for (var res in result.docs) {
      var ref = FirebaseStorage.instance.ref(destination + "/" + res.id);
      final list = await ref.listAll();
      for (var element in list.items) {
        FirebaseApi.deleteFile(element.fullPath);
      }
    }
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
