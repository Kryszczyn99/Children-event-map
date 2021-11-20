import 'package:children_event_map/screens/auth_folder/login.dart';
import 'package:children_event_map/screens/auth_folder/registry.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void changeView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return Login(changeView: changeView);
    } else {
      return Register(changeView: changeView);
    }
  }
}
