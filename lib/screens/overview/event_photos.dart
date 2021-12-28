import 'dart:io';

import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/services/firebaseapi.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

import 'package:intl/intl.dart';

class EventPhotos extends StatefulWidget {
  const EventPhotos(
      {required this.event_id,
      required this.post_id,
      required this.destination});

  final String event_id;
  final String post_id;
  final String destination;
  @override
  _EventPhotosState createState() => _EventPhotosState();
}

class _EventPhotosState extends State<EventPhotos> {
  List<String> paths = [];
  @override
  void initState() {
    super.initState();
    final resultList =
        FirebaseApi.getListOfImages(widget.destination).then((value) {
      for (var element in value) {
        setState(() {
          paths.add(element);
        });

        print(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.color3,
      appBar: AppBar(
        bottom: PreferredSize(
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(4.0),
        ),
        backgroundColor: MyColors.color5,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Photos ",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: paths.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: _getImage(context, paths[index]),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 3,
                      ),
                      Container(child: snapshot.data),
                      SizedBox(
                        height: 3,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ]),
      ),
    );
  }

  Future<Widget> _getImage(BuildContext context, String imageName) async {
    late Image image;
    try {
      await FirebaseApi.loadImage(context, imageName).then((value) {
        image = Image.network(
          value.toString(),
          fit: BoxFit.fill,
        );
      });
    } catch (err) {
      return Container();
    }

    return image;
  }
}
