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

class AdminUsers extends StatefulWidget {
  @override
  _AdminUsersState createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
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
          "Users",
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
                    hintText: 'Find user by email',
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
                SizedBox(
                  height: 15,
                ),
                Divider(
                  color: MyColors.color5,
                  thickness: 1,
                ),
                StreamBuilder(
                    stream: DatabaseService(uid: '')
                        .userCollection
                        .where('email', isGreaterThanOrEqualTo: text)
                        .where('email', isLessThan: text + 'z')
                        .snapshots(),
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
                                    width: MediaQuery.of(context).size.width *
                                        4 /
                                        5,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 30),
                                    decoration: BoxDecoration(
                                        color: MyColors.color5.withOpacity(0.8),
                                        border: Border.all(
                                            width: 3,
                                            color: MyColors.color4
                                                .withOpacity(0.8)),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "${document['email']}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                          visible: document['role'] == 'admin',
                                          child: Text(
                                            "Role: ${document['role']}",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Visibility(
                                          visible: document['role'] != 'admin',
                                          child: Text(
                                            "Role: ${document['role']}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            document['role'] == 'admin'
                                                ? TextButton.icon(
                                                    onPressed: () async {
                                                      await DatabaseService(
                                                              uid: '')
                                                          .becomeUser(
                                                              document.id);
                                                    },
                                                    icon: Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                    ),
                                                    label: Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  )
                                                : TextButton.icon(
                                                    onPressed: () async {
                                                      await DatabaseService(
                                                              uid: '')
                                                          .becomeAdmin(
                                                              document.id);
                                                    },
                                                    icon: Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                    ),
                                                    label: Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic),
                                                    ),
                                                  ),
                                            TextButton.icon(
                                              onPressed: () async {
                                                await DatabaseService(uid: '')
                                                    .banUser(document.id);
                                              },
                                              icon: Icon(
                                                Icons.block,
                                                color: Colors.red,
                                              ),
                                              label: Text(
                                                "Ban",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
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
