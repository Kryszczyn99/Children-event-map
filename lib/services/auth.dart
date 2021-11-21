import 'package:children_event_map/models/my_user.dart';
import 'package:children_event_map/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create users object
  MyUser? userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  Stream<MyUser?> get user {
    return _auth.authStateChanges().map(userFromFirebaseUser);
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign with @mail and pass
  Future loginUser(String email, String pass) async {
    try {
      UserCredential resValue =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User? u = resValue.user;
      return userFromFirebaseUser(u);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //reg @mail and pass
  Future registerUser(
      String email, String pass, String name, String surname) async {
    try {
      UserCredential resValue = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      User? u = resValue.user;
      await DatabaseService(uid: u!.uid)
          .setUserInformation(name, u.uid, email, surname);
      return userFromFirebaseUser(u);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //logout

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
