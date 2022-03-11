import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_list/models/friend.dart';

import '/providers/product.dart';
import '/providers/list.dart';

class Lists with ChangeNotifier {
  List<ShopingList> _lists = [];
  List _listUsers = [];
  bool isFetchingLists = false;

  FirebaseDatabase database = FirebaseDatabase.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List get listUsers {
    return [..._listUsers];
  }

  //update list's list
  void updateLists(data) {
    _lists = data;
    notifyListeners();
  }

  bool participant(listData) {
    if (listData['participants'] == null) return false;
    var usersList = listData['participants'];
    final fetchedList = jsonEncode(usersList);
    final decodedData = jsonDecode(fetchedList) as Map<String, dynamic>;
    bool part = false;
    decodedData.forEach((key, value) {
      if (value.containsValue(auth.currentUser!.uid)) part = true;
    });

    return part;
  }

  //set a listener in firebase
  void listsListener() {
    database.ref('lists').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final fetchedLists = jsonEncode(data);
        final decodedData = jsonDecode(fetchedLists) as Map<String, dynamic>;
        List<ShopingList> lists = [];
        decodedData.forEach((listId, listData) {
          if (listData['createdBy']['id'] == auth.currentUser!.uid ||
              participant(listData)) {
            List<Product> itemsList = [];
            var products = listData['items']['products'];
            if (products != null) {
              products.forEach(
                (prodId, prodData) {
                  Product product = Product(
                    amount: prodData['amount'],
                    id: prodId,
                    name: prodData['name'],
                    addedBy: {
                      'name': prodData['addedby']['name'],
                      'id': prodData['addedby']['id'],
                    },
                    completed: prodData['completed'],
                  );
                  itemsList.add(product);
                },
              );
            }

            List listParts = [];
            if (listData['participants'] != null) {
              listData['participants'].forEach((key, value) {
                listParts.add(value);
              });
            }

            ShopingList newList = ShopingList(
              createdAt: listData['createdAt'],
              id: listId,
              name: listData['name'],
              updatedAt: listData['updatedAt'],
              createdBy: listData['createdBy'] as Map<String, dynamic>,
              items: {
                'completed': listData['items']['completed'],
                'products': itemsList,
              },
              participants: listParts,
            );
            lists.add(newList);
          }
        });
        updateLists(lists);
      }
    });
  }

  //get all the lists
  List<ShopingList> get lists {
    return [..._lists];
  }

  //get single list
  ShopingList getList(String listId) {
    ShopingList currentList =
        lists.firstWhere((element) => element.id == listId);
    return currentList;
  }

  //create new list
  Future<void> createList(Map data) async {
    // data['participants'] = _listUsers;
    DatabaseReference ref = FirebaseDatabase.instance.ref("lists");
    await ref.push().set(data);
  }

  //add item to list
  Future<void> addItem(String listId, Map product) async {
    final newProductKey =
        database.ref().child('lists/$listId/items/products').push().key;
    database
        .ref('lists/$listId/items/products')
        .update({'$newProductKey': product});
  }

  //check uncheck item
  Future<void> checkItem(String itemId, String listId, bool value) async {
    database
        .ref('lists/$listId/items/products/$itemId')
        .update({'completed': value});
  }

  // add user to users list
  void addUser(user) {
    _listUsers.add(user);
    notifyListeners();
  }

  // remove user from users list
  void removeUser(user) {
    _listUsers.remove(user);
    notifyListeners();
  }

  //leave list
  Future<void> leaveList(String listid, String userId) async {
    final res = await database.ref('lists/$listid').get();
    if (res.exists) {
      final fetchedlist = jsonEncode(res.value);
      final decodedData = jsonDecode(fetchedlist) as Map<String, dynamic>;
      List participants = [];
      decodedData['participants']
          .forEach((key, value) => participants.add(value));
      var nextUser = participants[0];
      for (int i = 0; i < participants.length; i++) {
        if (participants[i]['id'] == userId) {
          database
              .ref('lists/$listid/participants/$i')
              .update({'active': false});
        } else if (userId == decodedData['createdBy']['id']) {
          database.ref('lists/$listid').update({'createdBy': nextUser});
        }
      }
    }
  }

  //delete list
  Future<void> deleteList(listId) async {
    await database.ref('lists/$listId').remove();
    _lists.removeWhere((element) => element.id == listId);
    notifyListeners();
  }

  //add user to existing list
  Future<void> addUserToList(String listId, Friend user) async {
    var participantsListRef = database.ref('lists/$listId/participants');
    var newUserRef = participantsListRef.push();
    newUserRef.set({
      'id': user.id,
      'active': true,
      'name': user.name,
    });
    notifyListeners();
  }

  //remove item from the list

  Future<void> removeItem(String itemId, String listId) async {
    await database.ref('lists/$listId/items/products/$itemId').remove();
  }
}
