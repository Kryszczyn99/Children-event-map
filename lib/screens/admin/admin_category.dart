import 'package:children_event_map/screens/admin/admin_lobby.dart';
import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AdminCategory extends StatefulWidget {
  @override
  _AdminCategoryState createState() => _AdminCategoryState();
}

class _AdminCategoryState extends State<AdminCategory> {
  int _selectedIndex = 0;
  String text = "";
  var uuid = Uuid();
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'New event'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];
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
      } else if (_selectedIndex == 2) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(),
          ),
        );
      } else if (_selectedIndex == 3) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminLobby(),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    DatabaseService(uid: '')
        .userCollection
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .first
        .then((user) => {
              if (user.docs.first.get("role") == "admin")
                {
                  setState(() {
                    items.add(
                      BottomNavigationBarItem(
                        label: "Admin",
                        icon: Icon(Icons.admin_panel_settings),
                      ),
                    );
                  }),
                },
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
        leadingWidth: 60,
        title: Text(
          "Category",
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
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Type category',
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
                    await DatabaseService(uid: '').addCategory(uid, text);
                    print(text);
                    showDialog(
                        context: context,
                        builder: (context) {
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.of(context).pop(true);
                          });
                          return AlertDialog(
                            title: Text(
                              'Added category!',
                              textAlign: TextAlign.center,
                            ),
                          );
                        });
                  },
                  child: Text('Add category'),
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  color: MyColors.color5,
                  thickness: 1,
                ),
                StreamBuilder(
                    stream:
                        DatabaseService(uid: '').categoryCollection.snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot2) {
                      if (!snapshot2.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Container(
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 20),
                          children: snapshot2.data!.docs.map((document) {
                            return Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 4 / 5,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 30),
                                  decoration: BoxDecoration(
                                      color: MyColors.color5.withOpacity(0.8),
                                      border: Border.all(
                                          width: 3,
                                          color:
                                              MyColors.color4.withOpacity(0.8)),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_sharp,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "${document['name']}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            await DatabaseService(uid: '')
                                                .deleteCategory(document.id);
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
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
