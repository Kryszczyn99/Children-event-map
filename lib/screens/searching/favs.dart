import 'package:children_event_map/screens/admin/admin_lobby.dart';
import 'package:children_event_map/screens/home/home.dart';
import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/screens/overview/event_overview.dart';
import 'package:children_event_map/screens/userEvents/event_info.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:custom_info_window/custom_info_window.dart';

import 'package:intl/intl.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
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
          "Favourites",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: DatabaseService(uid: '')
                  .favouriteCollection
                  .where('user_id',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                print(snapshot.data!.docs.length);

                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 20),
                  children: snapshot.data!.docs.map((document) {
                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 4 / 5,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          decoration: BoxDecoration(
                              color: MyColors.color5.withOpacity(0.8),
                              border: Border.all(
                                  width: 3,
                                  color: MyColors.color4.withOpacity(0.8)),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45))),
                          child: Column(
                            children: [
                              Text(
                                '#Favourite#',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "Voivodeship: ${document.get('voivodeship')}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "Category: ${document.get('category')}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                        Size(160, 50)),
                                    backgroundColor: MaterialStateProperty.all(
                                        MyColors.color5),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.white,
                                                width: 2,
                                                style: BorderStyle.solid),
                                            borderRadius:
                                                BorderRadius.circular(90.0)))),
                                child: Text(
                                  'Apply to the map',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(
                                        voivodeship:
                                            document.get('voivodeship'),
                                        category: document.get('category'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
