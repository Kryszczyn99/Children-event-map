import 'package:children_event_map/screens/auth_folder/authenticate.dart';
import 'package:children_event_map/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:children_event_map/models/my_user.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
    // return home or auth
  }
}
