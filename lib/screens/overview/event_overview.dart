import 'package:children_event_map/screens/overview/event_posts.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class EventOverView extends StatefulWidget {
  const EventOverView(
      {required this.date,
      required this.voivodeship,
      required this.city,
      required this.event_id,
      required this.latitude,
      required this.longitude,
      required this.description,
      required this.user_id,
      required this.tag,
      required this.participate});

  final String date;
  final String voivodeship;
  final String city;
  final String event_id;
  final String latitude;
  final String longitude;
  final String description;
  final String user_id;
  final String tag;
  final bool participate;
  @override
  _EventOverViewState createState() => _EventOverViewState();
}

class _EventOverViewState extends State<EventOverView> {
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
          "Details ",
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
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventPosts(
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                            event_id: widget.event_id),
                      ),
                    );
                  },
                  child: Text('Click here to see posts.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline,
                      )),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Voivodeship:',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '${widget.voivodeship}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  'City: ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '${widget.city}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Event starts: ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '${widget.date}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Description: ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '${widget.description}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Visibility(
                  visible: widget.participate == false,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(140, 35)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                    ),
                    onPressed: () async {
                      Widget cancelButton = TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                      Widget continueButton = TextButton(
                        child: Text("Continue"),
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          String uid_event_new = uuid.v4();
                          DatabaseService(uid: '').joinEvent(
                              widget.event_id,
                              FirebaseAuth.instance.currentUser!.uid,
                              uid_event_new);
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Text(
                                    'Joined event!',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                        },
                      );

                      // set up the AlertDialog
                      AlertDialog alert = AlertDialog(
                        title: Text("Alert"),
                        content: Text("Do you want to join event?"),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );

                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    child: Text('Join event'),
                  ),
                ),
                Visibility(
                  visible: widget.participate == true,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(140, 35)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                    ),
                    onPressed: () async {
                      Widget cancelButton = TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                      Widget continueButton = TextButton(
                        child: Text("Continue"),
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          DatabaseService(uid: '').leaveEvent(widget.event_id,
                              FirebaseAuth.instance.currentUser!.uid);
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Text(
                                    'You left event!',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                        },
                      );

                      // set up the AlertDialog
                      AlertDialog alert = AlertDialog(
                        title: Text("Alert"),
                        content: Text("Do you want to leave event?"),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );

                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    child: Text('Leave event'),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Visibility(
                  visible:
                      widget.user_id == FirebaseAuth.instance.currentUser!.uid,
                  child: Text(
                    'You are creator',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Visibility(
                  visible:
                      widget.user_id == FirebaseAuth.instance.currentUser!.uid,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        minimumSize: MaterialStateProperty.all(Size(140, 35)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)))),
                    onPressed: () async {
                      Widget cancelButton = TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );
                      Widget continueButton = TextButton(
                        child: Text("Continue"),
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          DatabaseService(uid: '').deleteEvent(widget.event_id);
                        },
                      );

                      // set up the AlertDialog
                      AlertDialog alert = AlertDialog(
                        title: Text("Alert"),
                        content: Text("Do you want to DELETE event?"),
                        actions: [
                          cancelButton,
                          continueButton,
                        ],
                      );

                      // show the dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    child: Text('Delete event'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
