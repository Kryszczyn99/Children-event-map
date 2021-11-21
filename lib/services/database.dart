import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('usersTable');
  /*
  final CollectionReference testCollection =
      FirebaseFirestore.instance.collection('test');
  Future test() async {
    QuerySnapshot result = await testCollection.get();
    List<DocumentSnapshot> documents = result.docs;
    return documents.length;
  }
  */
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
}
