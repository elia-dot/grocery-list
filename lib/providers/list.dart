import 'package:flutter/cupertino.dart';

class ShopingList with ChangeNotifier {
  String id;
  String name;
  String createdAt;
  String updatedAt;
  Map<String, dynamic> createdBy;
  Map items;

  ShopingList({
    required this.createdAt,
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.createdBy,
    required this.items,
  });
}
