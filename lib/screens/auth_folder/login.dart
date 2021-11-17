import 'package:children_event_map/services/auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService authService = AuthService();

  String email = '';
  String pass = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Sign in"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                obscureText: true,
                onChanged: (val) {
                  setState(() => pass = val);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              RaisedButton(
                color: Colors.pink[400],
                onPressed: () async {
                  print(email);
                  print(pass);
                },
                child: Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*
ElevatedButton(
          child: Text("Sign in anon"),
          onPressed: () async {
            dynamic result = await authService.signInAnon();
            if (result == null) {
              print('error');
            } else {
              print('logged');
            }
          },
        ),

        */