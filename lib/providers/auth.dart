import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grocery_list/models/friend.dart';

import '/models/user.dart';
import '/models/fb_exeption.dart';

class Auth with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;
  var authUser = AppUser(
    email: '',
    id: '',
    name: '',
    allowAdding: false,
    allowNotifications: {
      'addedToList': false,
      'itemAdded': false,
    },
    phone: '',
    friends: <Friend>[],
    requests: [],
  );
  List<Friend> _suggestions = [];

  List<Friend> get suggestios {
    return [..._suggestions];
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
        'allowAdding': true,
        'allowNotifications': {
          'addedToList': true,
          'itemAdded': false,
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
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw FBExeption('משתמש לא נמצא');
      } else if (e.code == 'wrong-password') {
        throw FBExeption('סיסמא לא נכונה');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAuthUser() async {
    String id = auth.currentUser!.uid;
    database.ref('users/$id').onValue.listen((event) {
      final user = event.snapshot.value;
      final fetchedUser = jsonEncode(user);
      final decodedData = jsonDecode(fetchedUser) as Map<String, dynamic>;
      List<Friend> friendsList = [];
      List requests = [];
      if (decodedData['friends'] != null) {
        decodedData['friends'].forEach((key, value) {
          Friend friend = Friend(
            id: value['id'],
            confirmed: value['confirmed'],
            name: value['name'],
            phone: value['phone'],
          );
          friendsList.add(friend);
        });
      }
      if (decodedData['requests'] != null) {
        decodedData['requests'].forEach((key, value) {
          var req = {
            'name': value['name'],
            'id': value['id'],
            'date': value['date'],
            'phone': value['phone'],
          };
          requests.add(req);
        });
      }
      authUser = AppUser(
        email: decodedData['email'],
        id: id,
        name: decodedData['name'],
        phone: decodedData['phone'],
        allowAdding: decodedData['allowAdding'],
        allowNotifications: decodedData['allowNotifications'],
        friends: friendsList,
        requests: requests,
      );
      notifyListeners();
    });
  }

  Future<void> updateNotifications(String setting, bool value) async {
    try {
      database
          .ref('users/${auth.currentUser!.uid}/allowNotifications')
          .update({setting: value});
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSettings(String setting, var value) async {
    try {
      database.ref('users/${auth.currentUser!.uid}').update({setting: value});
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  bool isFriend(String id) {
    for (Friend friend in authUser.friends) {
      if (friend.id == id) {
        return true;
      }
    }
    return false;
  }

  //search users
  Future<void> searchUser(String term, List friends, String userId) async {
    final res = await database.ref('users').get();
    if (res.exists) {
      final fetchedUser = jsonEncode(res.value);
      final decodedData = jsonDecode(fetchedUser) as Map<String, dynamic>;
      List<Friend> users = [];
      decodedData.forEach((key, value) {
        if (key != auth.currentUser!.uid &&
            !isFriend(key) &&
            term != '' &&
            (value['name'].contains(term) || value['phone'].contains(term))) {
          Friend user = Friend(
            id: key,
            confirmed: false,
            name: value['name'],
            phone: value['phone'],
          );
          users.add(user);
        }
      });
      _suggestions = users;
      notifyListeners();
    }
  }

  Future<void> addFriend(Friend friend) async {
    var userId = auth.currentUser!.uid;
    Map user = {
      'id': friend.id,
      'confirmed': friend.confirmed,
      'name': friend.name,
      'phone': friend.phone,
    };
    var friends = database.ref('users/$userId/friends');
    var newId = friends.push();
    newId.set(user);
    _suggestions.removeWhere((element) => element.id == friend.id);

    var requests = database.ref('users/${friend.id}/requests');
    var newReq = requests.push();
    newReq.set({
      'name': auth.currentUser!.displayName,
      'id': auth.currentUser!.uid,
      'phone': authUser.phone,
      'date': DateTime.now().toString(),
    });

    notifyListeners();
  }

  Future<void> resendReq(Friend friend) async {
    var requests = database.ref('users/${friend.id}/requests');
    bool exists = false;
    var requestsData = await requests.get();
    if (requestsData.exists) {
      final fetchedReq = jsonEncode(requestsData.value);
      final decodedData = jsonDecode(fetchedReq) as Map<String, dynamic>;
      decodedData.forEach((key, value) {
        if (value.containsValue(auth.currentUser!.uid)) {
          exists = true;
        }
      });
    }
    if (!exists) {
      var newReq = requests.push();
      newReq.set({
        'name': auth.currentUser!.displayName,
        'id': auth.currentUser!.uid,
        'phone': authUser.phone,
        'date': DateTime.now().toString(),
      });
    }
    notifyListeners();
  }

  Future<void> deleteRequest(String reqUserId) async {
    final reqRef =
        await database.ref('users/${auth.currentUser!.uid}/requests').get();
    final fetchedReq = jsonEncode(reqRef.value);
    final decodedData = jsonDecode(fetchedReq) as Map<String, dynamic>;
    String reqId = '';
    decodedData.forEach((key, value) {
      if (value['id'] == reqUserId) {
        reqId = key;
      }
    });
    await database
        .ref('users/${auth.currentUser!.uid}/requests/$reqId')
        .remove();
    notifyListeners();
  }

  //confirm friend request
  Future<void> confirmRequest(Map friend) async {
    var friends = database.ref('users/${auth.currentUser!.uid}/friends');
    var newFriend = friends.push();
    newFriend.set({
      'confirmed': true,
      'id': friend['id'],
      'name': friend['name'],
      'phone': friend['phone'],
    });
    deleteRequest(friend['id']);

    var senderFriends =
        await database.ref('users/${friend['id']}/friends').get();
    final fetchedReq = jsonEncode(senderFriends.value);
    final decodedData = jsonDecode(fetchedReq) as Map<String, dynamic>;

    String id = '';
    decodedData.forEach((key, value) {
      if (value['id'] == auth.currentUser!.uid) {
        id = key;
      }
    });
    await database
        .ref('users/${friend['id']}/friends/$id')
        .update({'confirmed': true});
  }

  //remove friend
  Future<void> removeFriend(String id) async {
    final friendsList =
        await database.ref('users/${auth.currentUser!.uid}/friends').get();
    final fetchedReq = jsonEncode(friendsList.value);
    final decodedData = jsonDecode(fetchedReq) as Map<String, dynamic>;
    String friendId = '';
    decodedData.forEach((key, value) {
      if (value['id'] == id) {
        friendId = key;
      }
    });
    await database
        .ref('users/${auth.currentUser!.uid}/friends/$friendId')
        .remove();

    final otherFriendsList = await database.ref('users/$id/friends').get();
    if (otherFriendsList.exists) {
      final otherfetchedReq = jsonEncode(otherFriendsList.value);
      final othedecodedData =
          jsonDecode(otherfetchedReq) as Map<String, dynamic>;
      String userId = '';
      othedecodedData.forEach((key, value) {
        if (value['id'] == auth.currentUser!.uid) {
          userId = key;
        }
      });
      await database.ref('users/$id/friends/$userId').remove();
    }

    final requestList = await database.ref('users/$id/requests').get();
    if (requestList.exists) {
      final otherRequestList = jsonEncode(requestList.value);
      final otherDecodedData =
          jsonDecode(otherRequestList) as Map<String, dynamic>;
      String requestUserId = '';
      otherDecodedData.forEach((key, value) {
        if (value['id'] == auth.currentUser!.uid) {
          requestUserId = key;
        }
      });
      await database.ref('users/$id/requests/$requestUserId').remove();
    }
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw FBExeption('נא הכנס אימייל תקין');
      } else if (e.code == 'user-not-found') {
        throw FBExeption('אימייל לא נמצא');
      }
    } catch (e) {
      rethrow;
    }
  }
}
