import 'package:children_event_map/screens/newEvent/create_event.dart';
import 'package:children_event_map/screens/userProfile/profile.dart';
import 'package:children_event_map/services/auth.dart';
import 'package:children_event_map/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService auth = AuthService();
  List<Marker> _markers = [];
  _handleTap(LatLng point) {
    setState(() {
      print("marker");
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(
          title: 'I am a marker',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
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
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: MyColors.color5,
            ),
            onPressed: () async {
              await auth.signOut();
            },
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: Text('logout', style: TextStyle(color: Colors.white)),
          ),
        ],
        title: const Text(
          "Home",
          style: TextStyle(fontSize: 34, fontStyle: FontStyle.italic),
        ),
      ),
      body: FutureBuilder<Position>(
          future: _determinePosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasData) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 200,
                      child: GoogleMap(
                        markers: Set<Marker>.of(_markers),
                        initialCameraPosition: CameraPosition(
                            target: LatLng(snapshot.data!.latitude,
                                snapshot.data!.longitude),
                            zoom: 15),
                        onTap: _handleTap,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          child: Text('Create new event'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateEvent(),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        ElevatedButton(
                          child: Text('Current'),
                          onPressed: () async {
                            Position position = await _determinePosition();
                            print(position);
                          },
                        ),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        ElevatedButton(
                          child: Text('Profile'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Profile(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
