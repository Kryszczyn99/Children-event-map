import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/screens/userEvents/event_info.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
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
        title: const Text(
          "My events",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: '')
              .participationCollection
              .where('user_id',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return StreamBuilder(
                stream: DatabaseService(uid: '')
                    .eventCollection
                    .orderBy('date', descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot2) {
                  if (!snapshot2.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.only(top: 20),
                    children: snapshot2.data!.docs.map((document) {
                      bool flag = false;
                      for (var variable in snapshot.data!.docs) {
                        if (variable.get('event_id') == document['event_id'])
                          flag = true;
                      }
                      if (flag == false) {
                        return Container();
                      }
                      //final doctors = snapshot2.data;
                      Timestamp temp = document['date'];
                      DateTime date = temp.toDate();
                      DateFormat displayFormater =
                          DateFormat('yyyy-MM-dd HH:mm:ss');
                      DateTime temp2 = displayFormater.parse(date.toString());
                      DateFormat serverFormater =
                          DateFormat('dd-MM-yyyy HH:mm');
                      String dateDisplay = serverFormater.format(temp2);
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
                                  '#Event#',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Text(
                                  "Date: $dateDisplay",
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
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              MyColors.color5),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.white,
                                                  width: 2,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      90.0)))),
                                  child: Text(
                                    'More information',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InfoEvent(
                                            date: dateDisplay,
                                            voivodeship:
                                                document['voivodeship'],
                                            city: document['city'],
                                            event_id: document['event_id'],
                                            latitude: document['latitude'],
                                            longitude: document['longitude'],
                                            description:
                                                document['description'],
                                            user_id: document['user_id']),
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
                });
          }),
    );
  }
}
