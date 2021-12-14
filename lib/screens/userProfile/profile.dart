import 'dart:io';

import 'package:children_event_map/screens/editing/editing.dart';
import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/services/firebaseapi.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:children_event_map/screens/userEvents/events.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late File file;
  final AuthService auth = AuthService();
  int _selectedIndex = 0;
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (_selectedIndex == 1) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateEvent(),
          ),
        );
      } else if (_selectedIndex == 2) ;
    });
  }

  @override
  Widget build(BuildContext context) {
    String email = "";
    String password = "";
    email = FirebaseAuth.instance.currentUser!.email.toString();
    //password = FirebaseAuth.instance.currentUser!
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
          "My Profile",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'New event'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.color5,
        unselectedItemColor: MyColors.color4,
        onTap: _onTapped,
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: '')
              .userCollection
              .where('userId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var user = snapshot.data!.docs[0];
              return Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.width * 1 / 10),
                            decoration: BoxDecoration(
                                color: MyColors.color5,
                                borderRadius: BorderRadius.circular(25)),
                            width: MediaQuery.of(context).size.width * 4 / 5,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                FutureBuilder(
                                  future: _getImage(context,
                                      "${FirebaseAuth.instance.currentUser!.uid}"),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Widget> snapshot) {
                                    if (snapshot.data.toString() ==
                                        "Container") {
                                      return Container(
                                        height: 140,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/person.png'),
                                            fit: BoxFit.fill,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        height: 140,
                                        width: 140,
                                        child: snapshot.data,
                                      );
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('User profile',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    '${user.get('name').toString()} ${user.get('surname').toString()}',
                                    //'user surname',
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.white)),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('${user.get('email')}',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white)),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.white,
                            height: 35,
                            thickness: 1,
                            indent: 45,
                            endIndent: 45,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Colors.white,
                                    primary: MyColors.color5,
                                    minimumSize: Size(165, 85),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Events()),
                                    );
                                  },
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('My events  ',
                                          style: TextStyle(fontSize: 16)),
                                      Icon(Icons.filter_frames),
                                    ],
                                  )),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Colors.white,
                                    primary: MyColors.color5,
                                    minimumSize: Size(165, 85),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditData(),
                                      ),
                                    );
                                  },
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('Edit data  ',
                                          style: TextStyle(fontSize: 16)),
                                      Icon(Icons.edit),
                                    ],
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Colors.white,
                                    primary: MyColors.color5,
                                    minimumSize: Size(165, 85),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final result = await FilePicker.platform
                                        .pickFiles(allowMultiple: false);
                                    final path = result!.files.single.path;

                                    setState(() {
                                      file = File(path!);
                                    });
                                    final destination =
                                        "${FirebaseAuth.instance.currentUser!.uid}";
                                    FirebaseApi.uploadFile(destination, file);

                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          Future.delayed(Duration(seconds: 1),
                                              () {
                                            Navigator.of(context).pop(true);
                                          });
                                          return AlertDialog(
                                            title: Text(
                                              'Zmieniono avatar!',
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        });
                                    await Future.delayed(Duration(seconds: 1));
                                    Navigator.pop(context);
                                  },
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('Upload photo',
                                          style: TextStyle(fontSize: 16)),
                                      Icon(Icons.download_sharp),
                                    ],
                                  )),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Colors.white,
                                    primary: MyColors.color5,
                                    minimumSize: Size(165, 85),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                    ),
                                  ),
                                  onPressed: () {
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
                                        await AuthService().deleteUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                                .toString());
                                      },
                                    );

                                    // set up the AlertDialog
                                    AlertDialog alert = AlertDialog(
                                      title: Text("Alert"),
                                      content: Text(
                                          "Do you want to delete your account?"),
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
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('Delete account  ',
                                          style: TextStyle(fontSize: 16)),
                                      Icon(Icons.delete),
                                    ],
                                  )),
                            ],
                          )
                        ],
                      )),
                ],
              );
            } else {
              return Container();
            }
          }),
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
