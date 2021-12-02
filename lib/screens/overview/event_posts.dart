import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:intl/intl.dart';

class EventPosts extends StatefulWidget {
  const EventPosts({
    required this.latitude,
    required this.longitude,
    required this.event_id,
  });
  final String latitude;
  final String longitude;
  final String event_id;
  @override
  _EventPostsState createState() => _EventPostsState();
}

class _EventPostsState extends State<EventPosts> {
  List<Marker> _markers = [];
  late LatLng point;
  @override
  void initState() {
    point =
        LatLng(double.parse(widget.latitude), double.parse(widget.longitude));
    _markers.add(Marker(
      markerId: MarkerId(point.toString()),
      position: point,
      infoWindow: InfoWindow(
        title: 'Event place',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    ));
  }

  String text = "";
  var uuid = Uuid();
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
          "Posts ",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: MyColors.color5,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Center(
                  child: Container(
                    color: Colors.white,
                    width: 300.0,
                    height: 500.0,
                    child: GoogleMap(
                      markers: Set<Marker>.of(_markers),
                      initialCameraPosition:
                          CameraPosition(target: point, zoom: 15),
                    ),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.map,
              color: Colors.white,
            ),
            label: Text('map', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Center(
            child: Column(children: <Widget>[
              TextFormField(
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Type text for post',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                onChanged: (val) {
                  setState(() => text = val);
                },
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(140, 35)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)))),
                onPressed: () async {
                  var uid = uuid.v4();
                  DateTime current_time = DateTime.now();
                  DatabaseService(uid: '').addPostToDB(
                      text,
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.event_id,
                      uid,
                      current_time);
                  showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.of(context).pop(true);
                        });
                        return AlertDialog(
                          title: Text(
                            'Published post!',
                            textAlign: TextAlign.center,
                          ),
                        );
                      });
                },
                child: Text('Publish post'),
              ),
              StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .postsCollection
                      .orderBy('date', descending: true)
                      .where('event_id', isEqualTo: widget.event_id)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 20),
                      children: snapshot.data!.docs.map((document) {
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
                                  Row(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.width /
                                                10,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                10,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/user.png'),
                                            fit: BoxFit.fill,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            child: Text(
                                              'Krzysztof Pijanowski',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            "$dateDisplay",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Center(
                                    child: Text(
                                      '${document['text']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
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
                  }),
            ]),
          ),
        ),
      ),
    );
  }
}



/*
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Type text for post',
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() => text = val);
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(140, 35)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(30.0)))),
                        onPressed: () async {
                          var uid = uuid.v4();
                          DateTime current_time = DateTime.now();
                          DatabaseService(uid: '').addPostToDB(
                              text,
                              FirebaseAuth.instance.currentUser!.uid,
                              widget.event_id,
                              uid,
                              current_time);
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Text(
                                    'Published post!',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                        },
                        child: Text('Publish post'),
                      ),
                      Container(
                        width: 500,
                        height: 400,
                        child: ListView(
                          padding: EdgeInsets.only(top: 20),
                          children: snapshot.data!.docs.map((document) {
                            bool flag = false;
                            for (var variable in snapshot.data!.docs) {
                              print('elo');
                            }
                            if (flag == false) {
                              return Container();
                            }
                            return Container(
                              child: Text('document[' ']'),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );*/