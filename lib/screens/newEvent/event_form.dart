import 'package:children_event_map/screens/home/home.dart';
import 'package:children_event_map/screens/newEvent/button_widget.dart';
import 'package:children_event_map/services/database.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FormEvent extends StatefulWidget {
  const FormEvent({Key? key, required this.longitude, required this.latitude})
      : super(key: key);
  final String longitude;
  final String latitude;
  @override
  _FormEventState createState() => _FormEventState();
}

class _FormEventState extends State<FormEvent> {
  final _formKey = GlobalKey<FormState>();

  String hour = "--";
  String minute = "--";
  String error = "";
  String description = "";
  String voivodeship = "";
  String city = "";
  String address = "";
  String tag = "";
  DateTime date = DateTime.now();

  var uuid = Uuid();

  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
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
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: MyColors.color5,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.cancel,
              color: Colors.white,
            ),
            label: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
        title: const Text(
          "Type info",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                    fillColor: MyColors.color3.withOpacity(0.4),
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 20, top: 15),
                    hintText: 'Voivodeship',
                    suffixIcon: Icon(Icons.location_city,
                        color: Colors.white, size: 25.0),
                  ),
                  onChanged: (val) {
                    setState(() => voivodeship = val);
                  },
                  validator: (val) => val!.isEmpty ? 'Enter voivodeship' : null,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                    fillColor: MyColors.color3.withOpacity(0.4),
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 20, top: 15),
                    hintText: 'City',
                    suffixIcon: Icon(Icons.location_city,
                        color: Colors.white, size: 25.0),
                  ),
                  onChanged: (val) {
                    setState(() => city = val);
                  },
                  validator: (val) => val!.isEmpty ? 'Enter city' : null,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                    fillColor: MyColors.color3.withOpacity(0.4),
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 20, top: 15),
                    hintText: 'Address (optional)',
                    suffixIcon: Icon(Icons.location_city,
                        color: Colors.white, size: 25.0),
                  ),
                  onChanged: (val) {
                    setState(() => address = val);
                  },
                ),
                const SizedBox(
                  height: 50.0,
                ),
                Text(
                  'Pick start event date',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: 40,
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.circular(5.0),
                        color: Colors.white,
                      ),
                      child: MaterialButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          "${selectedDate.toLocal()}".split(' ')[0],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 40,
                          child: ButtonWidget(
                            text: "${hour}:${minute}",
                            onClicked: () => _selectTime(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white, fontSize: 20),
                    fillColor: MyColors.color3.withOpacity(0.4),
                    filled: true,
                    contentPadding: EdgeInsets.only(left: 20, top: 15),
                    hintText: 'Keyword (max 25letters)',
                    suffixIcon:
                        Icon(Icons.light, color: Colors.white, size: 25.0),
                  ),
                  onChanged: (val) {
                    setState(() => tag = val);
                  },
                  validator: (val) =>
                      val!.isEmpty || val.length > 25 ? 'Type keyword' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => description = val);
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(
                  height: 60.0,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(140, 35)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)))),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (hour == "--" || minute == "--") {
                        setState(() {
                          error = "Give validate hours!";
                        });
                      } else if (description == "") {
                        setState(() {
                          error = "Give event a description!";
                        });
                      } else {
                        setState(() {
                          error = "";
                        });
                        var event_id = uuid.v4();
                        String onlyDate =
                            "${selectedDate.toLocal()}".split(' ')[0];
                        String wholeDate = onlyDate + " " + hour + ":" + minute;
                        DateTime dateOfTheEvent = DateTime.parse(wholeDate);
                        DatabaseService(uid: '').addEventToDatabase(
                            FirebaseAuth.instance.currentUser!.uid,
                            event_id,
                            dateOfTheEvent,
                            voivodeship,
                            city,
                            address,
                            description,
                            widget.longitude,
                            widget.latitude,
                            tag);
                        var new_participation_id = uuid.v4();
                        DatabaseService(uid: '').joinEvent(
                            event_id,
                            FirebaseAuth.instance.currentUser!.uid,
                            new_participation_id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Create event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021, 11),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime)
      setState(() {
        if (picked.hour >= 0 && picked.hour <= 9)
          hour = "0" + picked.hour.toString();
        else
          hour = picked.hour.toString();
        if (picked.minute >= 0 && picked.minute <= 9)
          minute = "0" + picked.minute.toString();
        else
          minute = picked.minute.toString();
        selectedTime = picked;
      });
  }
}
