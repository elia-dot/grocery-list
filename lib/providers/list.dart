import 'package:flutter/cupertino.dart';

class ShopingList with ChangeNotifier {
  String id;
  String name;
  String description;
  String createdAt;
  String updatedAt;
  String createdBy;

  ShopingList({
    required this.createdAt,
    required this.description,
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.createdBy,
  });
}
