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

  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('postTable');

  final CollectionReference likesCollection =
      FirebaseFirestore.instance.collection('likeTable');

  final CollectionReference voivodeshipCollection =
      FirebaseFirestore.instance.collection('voivodeship');

  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categoryTable');

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
    var result = await userCollection.where('userId', isEqualTo: uid).get();
    return await userCollection.doc(uid).update({
      'name': name,
      'surname': surname,
      'userId': uid,
      'email': result.docs[0].get('email'),
      'role': result.docs[0].get('role'),
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
    String tag,
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
      'tag': tag,
    });
  }

  Future leaveEvent(String event_id, String user_id) async {
    var result = await participationCollection
        .where('event_id', isEqualTo: event_id)
        .where('user_id', isEqualTo: user_id)
        .get();
    var data = result.docs[0];

    return await participationCollection.doc(data.id).delete();
  }

  Future deleteEvent(String event_id) async {
    await eventCollection.doc(event_id).delete();
    var result = await participationCollection
        .where('event_id', isEqualTo: event_id)
        .get();
    for (var current in result.docs) {
      await participationCollection.doc(current.id).delete();
    }
    result = await likesCollection.where('event_id', isEqualTo: event_id).get();
    for (var current in result.docs) {
      await likesCollection.doc(current.id).delete();
    }
    result = await postsCollection.where('event_id', isEqualTo: event_id).get();
    for (var current in result.docs) {
      await postsCollection.doc(current.id).delete();
    }
    return true;
  }

  Future joinEvent(String event_id, String user_id, String uid) async {
    await participationCollection.doc(uid).set({
      'event_id': event_id,
      'user_id': user_id,
    });
    return true;
  }

  Future doUserParticipateInEvent(String event_id, String user_id) async {
    var result = await participationCollection
        .where('event_id', isEqualTo: event_id)
        .where('user_id', isEqualTo: user_id)
        .get();
    if (result.docs.length > 0) return true;
    return false;
  }

  Future deletePost(String post_id) async {
    var result =
        await likesCollection.where('post_id', isEqualTo: post_id).get();
    for (var res in result.docs) {
      print(res.id);
      await likesCollection.doc(res.id).delete();
    }
    return await postsCollection.doc(post_id).delete();
  }

  Future addPostToDB(String text, String creator_id, String event_id,
      String uid, DateTime time, String name) async {
    await postsCollection.doc(uid).set({
      'event_id': event_id,
      'creator_id': creator_id,
      'text': text,
      'date': time,
      'author': name,
    });
    return false;
  }

  Future giveNameAndSurnameOfUserByID(String user_id) async {
    var result = await userCollection.where('userId', isEqualTo: user_id).get();
    String names =
        result.docs[0].get('name') + " " + result.docs[0].get('surname');
    return names;
  }

  Future giveLike(
      String user_id, String post_id, String uid, String event_id) async {
    return await likesCollection
        .doc(uid)
        .set({'user_id': user_id, 'post_id': post_id, 'event_id': event_id});
  }

  Future doItHaveLike(String user_id, String post_id) async {
    var result = await likesCollection
        .where('user_id', isEqualTo: user_id)
        .where('post_id', isEqualTo: post_id)
        .get();
    if (result.docs.length != 0) return true;
    return false;
  }

  Future cancelLike(String user_id, String post_id) async {
    var result = await likesCollection
        .where('user_id', isEqualTo: user_id)
        .where('post_id', isEqualTo: post_id)
        .get();
    await likesCollection.doc(result.docs[0].id).delete();
    return true;
  }

  Future getAllLikesByUserInEvent(String user_id, String event_id) async {
    return await likesCollection
        .where('user_id', isEqualTo: user_id)
        .where('event_id', isEqualTo: event_id)
        .get();
  }

  Future deleteCategory(String uid) async {
    return await categoryCollection.doc(uid).delete();
  }

  Future addCategory(String uid, String text) async {
    return categoryCollection.doc(uid).set({
      'name': text,
    });
  }

  Future becomeUser(String uid) async {
    var result = await userCollection.where('userId', isEqualTo: uid).get();

    return await userCollection.doc(uid).update({
      'name': result.docs[0].get('name'),
      'surname': result.docs[0].get('surname'),
      'userId': uid,
      'email': result.docs[0].get('email'),
      'role': 'user',
    });
  }

  Future becomeAdmin(String uid) async {
    var result = await userCollection.where('userId', isEqualTo: uid).get();
    return await userCollection.doc(uid).update({
      'name': result.docs[0].get('name'),
      'surname': result.docs[0].get('surname'),
      'userId': uid,
      'email': result.docs[0].get('email'),
      'role': 'admin',
    });
  }

  Future banUser(String uid) async {
    print('Przycisk ban nie jest zaimplementowany!');
  }

  Future getDate(String event_id) async {
    var result =
        await eventCollection.where('event_id', isEqualTo: event_id).get();
    return result.docs[0].get('date');
  }
}
