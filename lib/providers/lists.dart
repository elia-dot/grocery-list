import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';

import '/providers/list.dart';

class Lists with ChangeNotifier {
  List<ShopingList> _lists = [];

  FirebaseDatabase database = FirebaseDatabase.instance;

  //update list's list
  void updateLists(data) {
    _lists = data;
    notifyListeners();
  }

  //set a listener in fire base
  void listsListener() {
    database.ref('lists').onValue.listen((event) {
      final data = event.snapshot.value;
      final fetchedLists = jsonEncode(data);
      final decodedData = jsonDecode(fetchedLists) as Map<String, dynamic>;
      List<ShopingList> lists = [];
      decodedData.forEach((listId, listData) {
        ShopingList newList = ShopingList(
          createdAt: listData['createdAt'],
          description: listData['description'],
          id: listId,
          name: listData['name'],
          updatedAt: listData['updatedAt'],
          createdBy: listData['createdBy'],
        );
        lists.add(newList);
      });
      updateLists(lists);
    });
  }

  //get all the lists
  List<ShopingList> get lists {
    return [..._lists];
  }

  //create new list
  Future<void> createList(Map data) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("lists");
    await ref.push().set(data);
  }
}
