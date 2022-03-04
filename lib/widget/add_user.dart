import 'package:flutter/material.dart';
import 'package:grocery_list/helpers/avatar.dart';
import 'package:grocery_list/models/friend.dart';
import 'package:grocery_list/models/user.dart';
import 'package:grocery_list/providers/auth.dart';
import 'package:grocery_list/providers/lists.dart';
import 'package:provider/provider.dart';

class AddUser extends StatefulWidget {
  String func;
  String listId;
  AddUser({
    Key? key,
    required this.func,
    this.listId = '',
  }) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  String searchTerm = '';
  List<Friend> filteredFriends = [];

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<Auth>(context);
    AppUser authUser = authProvider.authUser;
    final listsProvider = Provider.of<Lists>(context);
    List<Friend> suggestions = authProvider.suggestios;
    var users = listsProvider.listUsers;
    List<Friend> friends = authUser.friends;

    void filterFriends(setState) {
      List<Friend> users = [];
      for (var friend in friends) {
        print(friend.name.contains(searchTerm));

        if (searchTerm != '' &&
            friend.confirmed &&
            (friend.name.contains(searchTerm) ||
                friend.phone.contains(searchTerm))) {
          if (widget.func == 'new') {
            users.add(friend);
          } else {
            var list = listsProvider.getList(widget.listId);
            var parts = list.participants;
            bool exist = false;
            for (Map existsUser in parts) {
              if (friend.id == existsUser['id']) {
                exist = true;
              }
            }
            if (!exist) {
              users.add(friend);
            }
          }
        }
      }
      setState(() {
        filteredFriends = users;
      });
    }

    bool checkUser(String id) {
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == id) return true;
      }
      return false;
    }

    void userClicked(listsProvider, user) {
      if (widget.func == 'friends') {
        authProvider.addFriend(user);
      }
      if (widget.func == 'new') {
        setState(() {
          filteredFriends.remove(user);
        });
        listsProvider.addUser(user);
      }
      if (widget.func == 'update') {
        setState(() {
          filteredFriends.remove(user);
        });
        listsProvider.addUserToList(widget.listId, user);
      }
      controller.clear();
    }

    return ChangeNotifierProvider.value(
      value: context.watch<Lists>(),
      child: StatefulBuilder(builder: (context, _setState) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.2),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.black),
                              focusNode: focusNode,
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "הכנס מס' טלפון או שם",
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (value) {
                                _setState(() {
                                  searchTerm = value;
                                });
                                if (widget.func == 'friends') {
                                  authProvider.searchUser(
                                      searchTerm, friends, authUser.id);
                                } else {
                                  filterFriends(_setState);
                                }
                              },
                            ),
                          ),
                          const Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                  if ((widget.func == 'new' || widget.func == 'update') &&
                      searchTerm != '' &&
                      filteredFriends.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (ctx, i) {
                          if (!checkUser(filteredFriends[i].id)) {
                            return InkWell(
                              onTap: () {
                                userClicked(listsProvider, filteredFriends[i]);
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                title: Text(filteredFriends[i].name),
                                trailing: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: buildAvatar(
                                      filteredFriends[i].name, context),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                        itemCount: filteredFriends.length,
                      ),
                    ),
                  if (widget.func == 'friends' &&
                      searchTerm != '' &&
                      suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (ctx, i) {
                          return InkWell(
                            onTap: () {
                              userClicked(listsProvider, suggestions[i]);
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              title: Text(suggestions[i].name),
                              trailing: SizedBox(
                                width: 40,
                                height: 40,
                                child:
                                    buildAvatar(suggestions[i].name, context),
                              ),
                            ),
                          );
                        },
                        itemCount: suggestions.length,
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
