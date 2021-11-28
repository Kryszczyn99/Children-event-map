import 'package:children_event_map/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('usersTable');

  final CollectionReference testCollection =
      FirebaseFirestore.instance.collection('testTable');

  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection('eventTable');

  final CollectionReference participationCollection =
      FirebaseFirestore.instance.collection('participationTable');

  Future setUserInformation(
      String name, String uid, String email, String surname) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'surname': surname,
      'userId': uid,
      'email': email,
      'role': 'user',
    });
  }

  Future modifyUserData(String name, String surname, String uid) async {
    print(uid);
    return await userCollection.doc(uid).update({
      'name': name,
      'surname': surname,
      'userId': uid,
      'email': 'krzychu@gmail.com',
      'role': 'user',
    });
  }

  Future test(String uid) async {
    return await testCollection.doc(uid).set({'test': uid});
  }

  Future deleteUserFromDB(String uid) async {
    await userCollection.doc(uid).delete();
    return true;
  }

  Future addEventToDatabase(
    String user_id,
    String event_id,
    DateTime date,
    String voivodeship,
    String city,
    String address,
    String description,
    String longitude,
    String latitude,
  ) async {
    return await eventCollection.doc(event_id).set({
      'user_id': user_id,
      'event_id': event_id,
      'date': date,
      'voivodeship': voivodeship,
      'city': city,
      'address': address,
      'description': description,
      'longitude': longitude,
      'latitude': latitude,
    });
  }
}
