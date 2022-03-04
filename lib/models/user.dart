import 'package:grocery_list/models/friend.dart';

class AppUser {
  String name;
  String email;
  String id;
  Map allowNotifications;
  bool allowAdding;
  String phone;
  List<Friend> friends;
  List requests;

  AppUser({
    required this.email,
    required this.id,
    required this.name,
    required this.allowAdding,
    required this.allowNotifications,
    required this.phone,
    required this.friends,
    required this.requests,
  });
}
