import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '/models/fb_exeption.dart';

class Auth with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  Future<void> signup(String name, String email, String password) async {
    try {
      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DatabaseReference ref =
          FirebaseDatabase.instance.ref("users/${user.user!.uid}");

      ref.set({
        'name': name,
        'email': user.user!.email,
      });
      await auth.currentUser!.updateDisplayName(name);
      await auth.currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw FBExeption('סיסמא חלשה');
      } else if (e.code == 'email-already-in-use') {
        throw FBExeption('אימייל כבר בשימוש');
      }
    } catch (e) {
      print('error: $e');
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        throw FBExeption('משתמש לא נמצא');
      } else if (e.code == 'wrong-password') {
        throw FBExeption('סיסמא לא נכונה');
      }
    } catch (e) {
      print('error: $e');
      throw e;
    }
  }
}
