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

class SearchMain extends StatefulWidget {
  const SearchMain({Key? key}) : super(key: key);

  @override
  _SearchMainState createState() => _SearchMainState();
}

class _SearchMainState extends State<SearchMain> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate2 = DateTime(
      DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);
  String voivodeship = "Wszystkie opcje";
  String tag = "Wszystkie opcje";
  bool voivodeshipCheckerflag = false;
  bool categoryCheckerflag = false;

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
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateEvent(),
          ),
        );
      } else if (_selectedIndex == 2) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(),
          ),
        );
      } else if (_selectedIndex == 3) {
        Navigator.pop(context);
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
          "Search",
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50.0,
              ),
              Text(
                'Event date picker',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 40,
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    child: MaterialButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 40,
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(5.0),
                      color: Colors.white,
                    ),
                    child: MaterialButton(
                      onPressed: () => _selectDate2(context),
                      child: Text(
                        "${selectedDate2.toLocal()}".split(' ')[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              StreamBuilder(
                stream:
                    DatabaseService(uid: '').voivodeshipCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<String> voivodeshipArray = [];
                  voivodeshipArray.add('Wszystkie opcje');
                  for (var voivo in snapshot.data!.docs) {
                    voivodeshipArray.add(voivo.get('name'));
                  }
                  //print(voivodeshipArray);
                  return Container(
                    width: 250,
                    padding: EdgeInsets.only(top: 15, right: 12),
                    child: DropdownButtonFormField<String>(
                      hint: Text(
                        'Voivodeship',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      dropdownColor: MyColors.color3,
                      elevation: 16,
                      icon: Icon(Icons.location_city,
                          color: Colors.white, size: 25.0),
                      style: TextStyle(color: MyColors.color3),
                      onChanged: (String? newValue) {
                        setState(() {
                          voivodeshipCheckerflag = true;
                          voivodeship = newValue!;
                        });
                      },
                      items: voivodeshipArray
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            child: Text(
                              value,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.0),
              StreamBuilder(
                stream: DatabaseService(uid: '').categoryCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<String> categoryArray = [];
                  categoryArray.add('Wszystkie opcje');
                  for (var voivo in snapshot.data!.docs) {
                    categoryArray.add(voivo.get('name'));
                  }
                  //print(voivodeshipArray);
                  return Container(
                    width: 250,
                    padding: EdgeInsets.only(top: 15, right: 12),
                    child: DropdownButtonFormField<String>(
                      hint: Text(
                        'Category',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      dropdownColor: MyColors.color3,
                      elevation: 16,
                      icon: Icon(Icons.location_city,
                          color: Colors.white, size: 25.0),
                      style: TextStyle(color: MyColors.color3),
                      onChanged: (String? newValue) {
                        setState(() {
                          categoryCheckerflag = true;
                          tag = newValue!;
                        });
                      },
                      items: categoryArray
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            child: Text(
                              value,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(200, 40)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        width: 1.0,
                        color: Colors.black,
                      ))),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(
                        voivodeship: voivodeship,
                        category: tag,
                      ),
                    ),
                  );
                },
                child: Text('Check it on map',
                    style: TextStyle(fontSize: 22, color: Colors.white)),
              ),
              Visibility(
                visible: tag == "Wszystkie opcje" &&
                    voivodeship == "Wszystkie opcje",
                child: StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      //.where('tag', isEqualTo: tag)
                      .where('date', isGreaterThanOrEqualTo: selectedDate)
                      .where('date', isLessThanOrEqualTo: selectedDate2)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    print(snapshot.data!.docs.length);

                    print("Wszystkie!");
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 20),
                      children: snapshot.data!.docs.map((document) {
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
                  },
                ),
              ),
              Visibility(
                visible: tag != "Wszystkie opcje" &&
                    voivodeship == "Wszystkie opcje",
                child: StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      .where('tag', isEqualTo: tag)
                      .where('date', isGreaterThanOrEqualTo: selectedDate)
                      .where('date', isLessThanOrEqualTo: selectedDate2)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    print(snapshot.data!.docs.length);
                    //print(voivodeshipArray);

                    print("Tag!");
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 20),
                      children: snapshot.data!.docs.map((document) {
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
                  },
                ),
              ),
              Visibility(
                visible: tag == "Wszystkie opcje" &&
                    voivodeship != "Wszystkie opcje",
                child: StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      .where('voivodeship', isEqualTo: voivodeship)
                      .where('date', isGreaterThanOrEqualTo: selectedDate)
                      .where('date', isLessThanOrEqualTo: selectedDate2)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    print(snapshot.data!.docs.length);
                    print("Voivodeship!");
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 20),
                      children: snapshot.data!.docs.map((document) {
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
                  },
                ),
              ),
              Visibility(
                visible: tag != "Wszystkie opcje" &&
                    voivodeship != "Wszystkie opcje",
                child: StreamBuilder(
                  stream: DatabaseService(uid: '')
                      .eventCollection
                      .where('voivodeship', isEqualTo: voivodeship)
                      .where('tag', isEqualTo: tag)
                      .where('date', isGreaterThanOrEqualTo: selectedDate)
                      .where('date', isLessThanOrEqualTo: selectedDate2)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    print(snapshot.data!.docs.length);
                    print("Dokładne!");
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 20),
                      children: snapshot.data!.docs.map((document) {
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021, 11),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021, 11),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate2)
      setState(() {
        selectedDate2 = picked;
      });
  }
}
