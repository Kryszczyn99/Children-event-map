import 'package:children_event_map/screens/admin/admin_category.dart';
import 'package:children_event_map/screens/admin/admin_users.dart';
import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/screens/searching/search_main.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminLobby extends StatefulWidget {
  @override
  _AdminLobbyState createState() => _AdminLobbyState();
}

class _AdminLobbyState extends State<AdminLobby> {
  int _selectedIndex = 0;
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'New event'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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

  /*
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
*/
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
          "Admin panel",
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
                const SizedBox(
                  height: 80.0,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(240, 60)),
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
                        builder: (context) => AdminCategory(),
                      ),
                    );
                  },
                  child: Text('Category settings',
                      style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(240, 60)),
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
                        builder: (context) => AdminUsers(),
                      ),
                    );
                  },
                  child: Text('User settings',
                      style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
