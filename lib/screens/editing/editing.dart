import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditData extends StatefulWidget {
  const EditData({Key? key}) : super(key: key);
  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  //const Home({Key? key}) : super(key: key);

  final AuthService auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String err = '';
  String name = '';
  String surname = '';
  int flag = 0;
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
        title: const Text(
          "Edit Data",
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
              if (flag == 0) {
                name = user.get('name').toString();
                surname = user.get('surname').toString();
                flag = 1;
              }
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        initialValue: '${user.get('name').toString()}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        decoration: InputDecoration(
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 20),
                          fillColor: MyColors.color3.withOpacity(0.4),
                          filled: true,
                          contentPadding: EdgeInsets.only(left: 20, top: 15),
                          suffixIcon: Icon(Icons.person,
                              color: Colors.white, size: 25.0),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your name' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        initialValue: '${user.get('surname').toString()}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        decoration: InputDecoration(
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 20),
                          fillColor: MyColors.color3.withOpacity(0.4),
                          filled: true,
                          contentPadding: EdgeInsets.only(left: 20, top: 15),
                          suffixIcon: Icon(Icons.person,
                              color: Colors.white, size: 25.0),
                        ),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your surname' : null,
                        onChanged: (val) {
                          setState(() => surname = val);
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
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
                          await DatabaseService(uid: '').modifyUserData(
                              name, surname, user.get('userId').toString());

                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                  title: Text(
                                    'Zmieniono dane!',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                        },
                        child: Text('Change data'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
