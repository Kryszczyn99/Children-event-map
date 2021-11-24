import 'package:children_event_map/screens/editing/editing.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  //const Home({Key? key}) : super(key: key);

  final AuthService auth = AuthService();
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
                                Container(
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
                                          builder: (context) => Profile()),
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
                                  onPressed: () {},
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('[Nothing here]  ',
                                          style: TextStyle(fontSize: 16)),
                                      //Icon(Icons.download_sharp),
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
}
