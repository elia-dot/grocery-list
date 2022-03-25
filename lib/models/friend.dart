import 'package:flutter/cupertino.dart';

class Friend with ChangeNotifier {
  String id;
  bool confirmed;
  String name;
  String phone;

  Friend({
    required this.id,
    required this.confirmed,
    required this.name,
    required this.phone,
  });
}
