import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '/models/user.dart';
import '/models/fb_exeption.dart';

class Auth with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  List _suggestionsList = [];

  List get suggestionsList {
    return [..._suggestionsList];
  }

  Future<void> signup(
      String name, String email, String password, String phone) async {
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
        'phone': phone,
        'allowAdding': false,
        'allowNotifications': {
          'addedToList': true,
          'itemAdded': true,
        },
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

  Future<AppUser?> getUser(String id) async {
    final res = await database.ref('users/$id').get();
    if (res.exists) {
      var user;
      final fetchedUser = jsonEncode(res.value);
      final decodedData = jsonDecode(fetchedUser) as Map<String, dynamic>;
      user = AppUser(
          email: decodedData['email'],
          id: id,
          name: decodedData['name'],
          phone: decodedData['phone'],
          allowAdding: decodedData['allowAdding'],
          allowNotifications: decodedData['allowNotifications'],
          friends: decodedData['friends'] ?? []);

      return user;
    } else {
      print('no Data');
    }
  }

  Future<void> updateNotifications(String setting, bool value) async {
    try {
      database
          .ref('users/${auth.currentUser!.uid}/allowNotifications')
          .update({setting: value});
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateSettings(String setting, String value) async {
    try {
      database.ref('users/${auth.currentUser!.uid}').update({setting: value});
    } catch (e) {
      print(e);
    }
  }

  Future<void> searchUser(String term) async {
    final res = await database.ref('users').get();
    List users = [];
    if (res.exists) {
      final fetchedUser = jsonEncode(res.value);
      final decodedData = jsonDecode(fetchedUser) as Map<String, dynamic>;
      decodedData.forEach((key, value) {
        if (key != auth.currentUser!.uid &&
            term != '' &&
            (value['name'].contains(term) || value['phone'].contains(term))) {
          final user = {
            'id': key,
            'name': value['name'],
          };
          users.add(user);
        }
      });
      _suggestionsList = users;
      notifyListeners();
    }
  }
}
