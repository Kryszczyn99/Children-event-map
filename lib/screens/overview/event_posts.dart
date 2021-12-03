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
    required this.event_creator,
  });
  final String latitude;
  final String longitude;
  final String event_id;
  final String event_creator;
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
              SizedBox(
                height: 20,
              ),
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
                  var user_name = await DatabaseService(uid: '')
                      .giveNameAndSurnameOfUserByID(
                          FirebaseAuth.instance.currentUser!.uid);
                  DatabaseService(uid: '').addPostToDB(
                      text,
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.event_id,
                      uid,
                      current_time,
                      user_name);
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
                                          Visibility(
                                            visible: widget.event_creator !=
                                                document['creator_id'],
                                            child: Container(
                                              child: Text(
                                                '${document['author']}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: widget.event_creator ==
                                                document['creator_id'],
                                            child: Container(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "${document['author']} ",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    WidgetSpan(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 22,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      StreamBuilder(
                                          stream: DatabaseService(uid: '')
                                              .likesCollection
                                              .where('user_id',
                                                  isEqualTo: FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid)
                                              .where('event_id',
                                                  isEqualTo: widget.event_id)
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot2) {
                                            if (!snapshot2.hasData) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            return StreamBuilder(
                                              stream: DatabaseService(uid: '')
                                                  .likesCollection
                                                  .where('post_id',
                                                      isEqualTo: document.id)
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot3) {
                                                if (!snapshot3.hasData) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                }
                                                int len = 0;
                                                for (var temp
                                                    in snapshot3.data!.docs) {
                                                  len = len + 1;
                                                }
                                                bool value = false;
                                                for (var temp
                                                    in snapshot2.data!.docs) {
                                                  if (temp.get('user_id') ==
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid &&
                                                      temp.get('post_id') ==
                                                          document.id)
                                                    value = true;
                                                }
                                                if (value == true) {
                                                  return TextButton.icon(
                                                    onPressed: () async {
                                                      await DatabaseService(
                                                              uid: '')
                                                          .cancelLike(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              document.id);
                                                    },
                                                    icon: Icon(
                                                      Icons.thumb_up_sharp,
                                                      color: Colors.blue,
                                                    ),
                                                    label: Text(
                                                      "Like ($len)",
                                                      style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 14,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  );
                                                }
                                                return TextButton.icon(
                                                  onPressed: () async {
                                                    var generated_id =
                                                        uuid.v4();
                                                    DatabaseService(uid: '')
                                                        .giveLike(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            document.id,
                                                            generated_id,
                                                            widget.event_id);
                                                  },
                                                  icon: Icon(
                                                    Icons.thumb_up_sharp,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    "Like ($len)",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                );
                                              },
                                            );
                                          }),
                                      Visibility(
                                        visible: FirebaseAuth
                                                .instance.currentUser!.uid ==
                                            document['creator_id'],
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              await DatabaseService(uid: '')
                                                  .deletePost(document.id);
                                            },
                                            icon: Icon(
                                              Icons.restore_from_trash_sharp,
                                              color: Colors.red,
                                            ),
                                            label: Text(
                                              "",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
