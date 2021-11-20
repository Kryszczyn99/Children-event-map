import 'package:children_event_map/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  //const Register({Key? key}) : super(key: key);

  final Function changeView;
  const Register({required this.changeView});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String pass = '';
  String err = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        title: Text("Register"),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              widget.changeView();
            },
            icon: Icon(Icons.person),
            label: Text('Login'),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                obscureText: true,
                validator: (val) =>
                    val!.length < 8 ? 'Enter a password 8+ chars long' : null,
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
                  if (_formKey.currentState!.validate()) {
                    dynamic resValue =
                        await authService.registerUser(email, pass);
                    if (resValue == null) {
                      setState(() => err = 'Give valid email or password');
                    }
                  }
                },
                child: Text('Register'),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                err,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
