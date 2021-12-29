import 'package:children_event_map/main.dart';
import 'package:children_event_map/screens/admin/admin_lobby.dart';
import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/screens/overview/event_overview.dart';
import 'package:children_event_map/screens/searching/search_main.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:custom_info_window/custom_info_window.dart';

import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({required this.category, required this.voivodeship});
  final String category;
  final String voivodeship;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService auth = AuthService();
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  bool filters = false;
  List<Marker> _markers = [];
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'New event'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
  ];

  int _selectedIndex = 0;
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (_selectedIndex == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateEvent(),
          ),
        );
      } else if (_selectedIndex == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(),
          ),
        );
      } else if (_selectedIndex == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchMain(),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    print(widget.category);
    print(widget.voivodeship);
    setState(() {
      if (!((widget.category == "" || widget.category == "Wszystkie opcje") &&
          (widget.voivodeship == "" ||
              widget.voivodeship == "Wszystkie opcje"))) filters = true;
    });
    print(filters);
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        String? test1 = notification.title;
        String? test2 = notification.body;
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(test1!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(test2!)],
                  ),
                ),
              );
            });
      }
    });
  }

  void scheduleNotificationsTest() {
    var scheduledNotificationDateTime =
        new DateTime.now().add(Duration(seconds: 10));
    flutterLocalNotificationsPlugin.schedule(
        1,
        'Test',
        'Test2',
        scheduledNotificationDateTime,
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  void showNotification() {
    flutterLocalNotificationsPlugin.show(
        0,
        "Testing ",
        "How you doin ?",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
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
        leadingWidth: 60,
        leading: Visibility(
          visible: filters == true,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: MyColors.color5,
            ),
            onPressed: () async {
              setState(() {
                filters = false;
                //widget.category = "";
                //widget.voivodeship = "";
              });
            },
            icon: Icon(
              Icons.filter,
              color: Colors.red,
            ),
            label: Container(),
          ),
        ),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: MyColors.color5,
            ),
            onPressed: () async {
              Navigator.of(context).popUntil((route) => route.isFirst);
              await auth.signOut();
              //scheduleNotificationsTest();
            },
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text('logout', style: TextStyle(color: Colors.white)),
          ),
        ],
        title: Text(
          "Home",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: List.of(items),
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.color5,
        unselectedItemColor: MyColors.color4,
        onTap: _onTapped,
      ),
      body: FutureBuilder<Position>(
          future: _determinePosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasData && filters == false) {
              return StreamBuilder(
                  stream: DatabaseService(uid: '').eventCollection.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot2) {
                    if (!snapshot2.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    _markers.clear();
                    for (var result in snapshot2.data!.docs) {
                      String log = result.get('longitude');
                      String lat = result.get('latitude');
                      LatLng pos = LatLng(double.parse(lat), double.parse(log));
                      Timestamp temp = result.get('date');
                      DateTime date = temp.toDate();
                      DateFormat displayFormater =
                          DateFormat('yyyy-MM-dd HH:mm:ss');
                      DateTime temp2 = displayFormater.parse(date.toString());
                      DateFormat serverFormater =
                          DateFormat('dd-MM-yyyy HH:mm');
                      String dateDisplay = serverFormater.format(temp2);
                      _markers.add(
                        Marker(
                          markerId: MarkerId(pos.toString()),
                          position: pos,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueMagenta),
                          onTap: () {
                            _customInfoWindowController.addInfoWindow!(
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(45),
                                    border: Border.all(color: MyColors.color5)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          Text(
                                            "$dateDisplay",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Category: ${result.get('tag')}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                MyColors.color4
                                                    .withOpacity(0.5)),
                                      ),
                                      onPressed: () async {
                                        var res = await DatabaseService(uid: '')
                                            .doUserParticipateInEvent(
                                                result['event_id'],
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        print(res);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventOverView(
                                                date: dateDisplay,
                                                voivodeship:
                                                    result['voivodeship'],
                                                city: result['city'],
                                                event_id: result['event_id'],
                                                latitude: result['latitude'],
                                                longitude: result['longitude'],
                                                description:
                                                    result['description'],
                                                user_id: result['user_id'],
                                                tag: result['tag'],
                                                participate: res),
                                          ),
                                        );
                                      },
                                      child: Text("See more info"),
                                    ),
                                  ],
                                ),
                              ),
                              pos,
                            );
                          },
                        ),
                      );
                    }
                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          onTap: (position) {
                            _customInfoWindowController.hideInfoWindow!();
                          },
                          onCameraMove: (position) {
                            _customInfoWindowController.onCameraMove!();
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            _customInfoWindowController.googleMapController =
                                controller;
                          },
                          markers: Set<Marker>.of(_markers),
                          initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 10,
                          ),
                        ),
                        CustomInfoWindow(
                          controller: _customInfoWindowController,
                          height: 125,
                          width: 185,
                          offset: 50,
                        ),
                      ],
                    );
                    //tutaj kod
                  });
            } else if (snapshot.hasData &&
                (widget.category == "Wszystkie opcje" ||
                    widget.category == "")) {
              return StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      .where('voivodeship', isEqualTo: widget.voivodeship)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot2) {
                    if (!snapshot2.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    _markers.clear();
                    for (var result in snapshot2.data!.docs) {
                      String log = result.get('longitude');
                      String lat = result.get('latitude');
                      LatLng pos = LatLng(double.parse(lat), double.parse(log));
                      Timestamp temp = result.get('date');
                      DateTime date = temp.toDate();
                      DateFormat displayFormater =
                          DateFormat('yyyy-MM-dd HH:mm:ss');
                      DateTime temp2 = displayFormater.parse(date.toString());
                      DateFormat serverFormater =
                          DateFormat('dd-MM-yyyy HH:mm');
                      String dateDisplay = serverFormater.format(temp2);
                      _markers.add(
                        Marker(
                          markerId: MarkerId(pos.toString()),
                          position: pos,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueMagenta),
                          onTap: () {
                            _customInfoWindowController.addInfoWindow!(
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(45),
                                    border: Border.all(color: MyColors.color5)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          Text(
                                            "$dateDisplay",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Category: ${result.get('tag')}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                MyColors.color4
                                                    .withOpacity(0.5)),
                                      ),
                                      onPressed: () async {
                                        var res = await DatabaseService(uid: '')
                                            .doUserParticipateInEvent(
                                                result['event_id'],
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        print(res);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventOverView(
                                                date: dateDisplay,
                                                voivodeship:
                                                    result['voivodeship'],
                                                city: result['city'],
                                                event_id: result['event_id'],
                                                latitude: result['latitude'],
                                                longitude: result['longitude'],
                                                description:
                                                    result['description'],
                                                user_id: result['user_id'],
                                                tag: result['tag'],
                                                participate: res),
                                          ),
                                        );
                                      },
                                      child: Text("See more info"),
                                    ),
                                  ],
                                ),
                              ),
                              pos,
                            );
                          },
                        ),
                      );
                    }
                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          onTap: (position) {
                            _customInfoWindowController.hideInfoWindow!();
                          },
                          onCameraMove: (position) {
                            _customInfoWindowController.onCameraMove!();
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            _customInfoWindowController.googleMapController =
                                controller;
                          },
                          markers: Set<Marker>.of(_markers),
                          initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 10,
                          ),
                        ),
                        CustomInfoWindow(
                          controller: _customInfoWindowController,
                          height: 125,
                          width: 185,
                          offset: 50,
                        ),
                      ],
                    );
                    //tutaj kod
                  });
            } else if (snapshot.hasData &&
                (widget.voivodeship == "Wszystkie opcje" ||
                    widget.voivodeship == "")) {
              return StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      .where('tag', isEqualTo: widget.category)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot2) {
                    if (!snapshot2.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    _markers.clear();
                    for (var result in snapshot2.data!.docs) {
                      String log = result.get('longitude');
                      String lat = result.get('latitude');
                      LatLng pos = LatLng(double.parse(lat), double.parse(log));
                      Timestamp temp = result.get('date');
                      DateTime date = temp.toDate();
                      DateFormat displayFormater =
                          DateFormat('yyyy-MM-dd HH:mm:ss');
                      DateTime temp2 = displayFormater.parse(date.toString());
                      DateFormat serverFormater =
                          DateFormat('dd-MM-yyyy HH:mm');
                      String dateDisplay = serverFormater.format(temp2);
                      _markers.add(
                        Marker(
                          markerId: MarkerId(pos.toString()),
                          position: pos,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueMagenta),
                          onTap: () {
                            _customInfoWindowController.addInfoWindow!(
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(45),
                                    border: Border.all(color: MyColors.color5)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          Text(
                                            "$dateDisplay",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Category: ${result.get('tag')}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                MyColors.color4
                                                    .withOpacity(0.5)),
                                      ),
                                      onPressed: () async {
                                        var res = await DatabaseService(uid: '')
                                            .doUserParticipateInEvent(
                                                result['event_id'],
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        print(res);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventOverView(
                                                date: dateDisplay,
                                                voivodeship:
                                                    result['voivodeship'],
                                                city: result['city'],
                                                event_id: result['event_id'],
                                                latitude: result['latitude'],
                                                longitude: result['longitude'],
                                                description:
                                                    result['description'],
                                                user_id: result['user_id'],
                                                tag: result['tag'],
                                                participate: res),
                                          ),
                                        );
                                      },
                                      child: Text("See more info"),
                                    ),
                                  ],
                                ),
                              ),
                              pos,
                            );
                          },
                        ),
                      );
                    }
                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          onTap: (position) {
                            _customInfoWindowController.hideInfoWindow!();
                          },
                          onCameraMove: (position) {
                            _customInfoWindowController.onCameraMove!();
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            _customInfoWindowController.googleMapController =
                                controller;
                          },
                          markers: Set<Marker>.of(_markers),
                          initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 10,
                          ),
                        ),
                        CustomInfoWindow(
                          controller: _customInfoWindowController,
                          height: 125,
                          width: 185,
                          offset: 50,
                        ),
                      ],
                    );
                    //tutaj kod
                  });
            } else if (snapshot.hasData && filters == true) {
              return StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      .where('voivodeship', isEqualTo: widget.voivodeship)
                      .where('tag', isEqualTo: widget.category)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot2) {
                    if (!snapshot2.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    _markers.clear();
                    for (var result in snapshot2.data!.docs) {
                      String log = result.get('longitude');
                      String lat = result.get('latitude');
                      LatLng pos = LatLng(double.parse(lat), double.parse(log));
                      Timestamp temp = result.get('date');
                      DateTime date = temp.toDate();
                      DateFormat displayFormater =
                          DateFormat('yyyy-MM-dd HH:mm:ss');
                      DateTime temp2 = displayFormater.parse(date.toString());
                      DateFormat serverFormater =
                          DateFormat('dd-MM-yyyy HH:mm');
                      String dateDisplay = serverFormater.format(temp2);
                      _markers.add(
                        Marker(
                          markerId: MarkerId(pos.toString()),
                          position: pos,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueMagenta),
                          onTap: () {
                            _customInfoWindowController.addInfoWindow!(
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(45),
                                    border: Border.all(color: MyColors.color5)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 8.0,
                                          ),
                                          Text(
                                            "$dateDisplay",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Category: ${result.get('tag')}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                MyColors.color4
                                                    .withOpacity(0.5)),
                                      ),
                                      onPressed: () async {
                                        var res = await DatabaseService(uid: '')
                                            .doUserParticipateInEvent(
                                                result['event_id'],
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        print(res);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventOverView(
                                                date: dateDisplay,
                                                voivodeship:
                                                    result['voivodeship'],
                                                city: result['city'],
                                                event_id: result['event_id'],
                                                latitude: result['latitude'],
                                                longitude: result['longitude'],
                                                description:
                                                    result['description'],
                                                user_id: result['user_id'],
                                                tag: result['tag'],
                                                participate: res),
                                          ),
                                        );
                                      },
                                      child: Text("See more info"),
                                    ),
                                  ],
                                ),
                              ),
                              pos,
                            );
                          },
                        ),
                      );
                    }
                    return Stack(
                      children: <Widget>[
                        GoogleMap(
                          onTap: (position) {
                            _customInfoWindowController.hideInfoWindow!();
                          },
                          onCameraMove: (position) {
                            _customInfoWindowController.onCameraMove!();
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            _customInfoWindowController.googleMapController =
                                controller;
                          },
                          markers: Set<Marker>.of(_markers),
                          initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 10,
                          ),
                        ),
                        CustomInfoWindow(
                          controller: _customInfoWindowController,
                          height: 125,
                          width: 185,
                          offset: 50,
                        ),
                      ],
                    );
                    //tutaj kod
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
