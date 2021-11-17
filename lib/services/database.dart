import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference testCollection =
      FirebaseFirestore.instance.collection('test');
  Future test() async {
    QuerySnapshot result = await testCollection.get();
    List<DocumentSnapshot> documents = result.docs;
    return documents.length;
  }
}
