import 'package:flutter/cupertino.dart';

class Product with ChangeNotifier {
  String id;
  String name;
  String amount;
  bool completed;
  Map addedBy;

  Product({
    required this.amount,
    this.completed = false,
    required this.id,
    required this.name,
    required this.addedBy,
  });
}
