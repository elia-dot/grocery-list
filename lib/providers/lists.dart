import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/providers/product.dart';
import '/providers/list.dart';

class Lists with ChangeNotifier {
  List<ShopingList> _lists = [];

  FirebaseDatabase database = FirebaseDatabase.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  //update list's list
  void updateLists(data) {
    _lists = data;
    notifyListeners();
  }

  //set a listener in fire base
  void listsListener() {
    database.ref('lists').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final fetchedLists = jsonEncode(data);
        final decodedData = jsonDecode(fetchedLists) as Map<String, dynamic>;
        List<ShopingList> lists = [];
        decodedData.forEach((listId, listData) {
          if (listData['createdBy']['id'] == auth.currentUser!.uid) {
            List<Product> itemsList = [];
            var products = listData['items']['products'];
            if (products != null) {
              products.forEach(
                (prodId, prodData) {
                  Product product = Product(
                    amount:prodData['amount'],
                    id: prodId,
                    name: prodData['name'],
                    addedBy: {
                      'name': prodData['addedby']['name'],
                      'id': prodData['addedby']['id'],
                    },
                  );
                  itemsList.add(product);
                },
              );
            }

            ShopingList newList = ShopingList(
              createdAt: listData['createdAt'],
              description: listData['description'],
              id: listId,
              name: listData['name'],
              updatedAt: listData['updatedAt'],
              createdBy: listData['createdBy'] as Map<String, dynamic>,
              items: {
                'completed': listData['items']['completed'],
                'products': itemsList,
              },
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
}
