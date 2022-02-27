import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';

import '/models/user.dart';
import '/providers/auth.dart';
import '/providers/product.dart';
import '/screens/list_products.dart';
import '/providers/list.dart';
import '/providers/lists.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late var authUser;
  Map<String, dynamic> listData = {
    'name': '',
    'createdBy': {},
    'updatedAt': '',
    'createdAt': '',
    'items': {'completed': false, 'itemsList': <Product>[]},
  };
  var _isLoading = false;

  TextEditingController controller = TextEditingController();

  Future<void> submit() async {
    final listsProvider = Provider.of<Lists>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    listData['createdBy'] = {
      'id': auth.currentUser!.uid,
      'name': auth.currentUser!.displayName,
    };
    listData['createdAt'] = DateTime.now().toString();
    listData['updatedAt'] = DateTime.now().toString();

    await listsProvider.createList(listData);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  Future<AppUser?> getUser() async {
    AppUser? user = await Provider.of<Auth>(context, listen: false)
        .getUser(auth.currentUser!.uid);
    authUser = user;

    return user;
  }

  @override
  void initState() {
    final listsProvider = Provider.of<Lists>(context, listen: false);
    listsProvider.listsListener();
    getUser();
    super.initState();
  }

  int countItems(items) {
    if (items == null) return 0;
    int count = 0;
    for (int i = 0; i < items.length; i++) {
      if (items[i].completed) {
        count++;
      }
    }
    return count;
  }

  double dividerWidth(int total, int completed) {
    if (total == 0 || completed == 0) return 0;
    return completed / total;
  }

  void showList(String listId) {
    showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return ListProducts(
            listId: listId,
          );
        });
  }

  bool checkUser(String id, users) {
    for (int i = 0; i < users.length; i++) {
      if (users[i]['id'] == id) return true;
    }
    return false;
  }

  Widget usersSuggestion(ctx, _setState, users) {
    final listsProvider = Provider.of<Lists>(context);
    var suggestions = listsProvider.suggestios;
    FocusNode focusNode = FocusNode();
    String searchTerm = '';

    var res = Container(
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
                        listsProvider.searchUser(value);
                      },
                    ),
                  ),
                  const Icon(Icons.search),
                ],
              ),
            ),
          ),
          if (searchTerm == '' && authUser.friends.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, i) {
                  if (!checkUser(authUser.friends[i]['id'], users)) {
                    return InkWell(
                      onTap: () {
                        listsProvider.addUser(authUser.friends[i]);
                        controller.clear();
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        title: Text(authUser.friends[i]['name']),
                        trailing: SizedBox(
                          width: 40,
                          height: 40,
                          child:
                              buildAvatar(authUser.friends[i]['name'], context),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
                itemCount: authUser.friends.length,
              ),
            ),
          if (searchTerm == '' && suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, i) {
                  if (!checkUser(suggestions[i]['id'], users)) {
                    return InkWell(
                      onTap: () {
                        listsProvider.addUser(suggestions[i]);
                        controller.clear();
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        title: Text(suggestions[i]['name']),
                        trailing: SizedBox(
                          width: 40,
                          height: 40,
                          child: buildAvatar(suggestions[i]['name'], context),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
                itemCount: suggestions.length,
              ),
            )
        ],
      ),
    );

    return res;
  }

  List<Widget> participants() {
    var listsProvider = Provider.of<Lists>(context);
    var users = listsProvider.listUsers;
    List<Widget> res = users
        .map(
          (e) => SizedBox(
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => listsProvider.removeUser(e),
              child: Badge(
                position: const BadgePosition(
                  top: -5,
                  start: -5,
                ),
                badgeContent: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 10,
                ),
                child: buildAvatar(e['name'], context),
              ),
            ),
          ),
        )
        .toList();
    res.insert(
      0,
      SizedBox(
        width: 40,
        height: 40,
        child: buildAvatar(auth.currentUser!.displayName!, context),
      ),
    );
    res.add(
      SizedBox(
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider.value(
                      value: context.watch<Lists>(),
                      child: StatefulBuilder(
                        builder: (ctx, _setState) => Dialog(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Container(
                              child: usersSuggestion(ctx, _setState, users),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
    return res;
  }

  Widget buildNewList() {
    return StatefulBuilder(
      builder: (context, setState) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: submit,
                child: Text(
                  'יצירה',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(26.0),
                      child: Text(
                        'רשימה חדשה',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'שם:',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          listData['name'] = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('משתתפים:'),
                          const SizedBox(
                            height: 10,
                          ),
                          Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: participants(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ShopingList> lists = Provider.of<Lists>(context).lists;
    return Column(
      children: [
        const Center(
          child: Text(
            'הרשימות שלי:',
            style: TextStyle(
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, i) {
              String listCreator =
                  lists[i].createdBy['id'] == auth.currentUser!.uid
                      ? 'נוצר על ידך'
                      : 'נוצר על ידי ${lists[i].createdBy['name']}';
              int totalItems = (lists[i].items['products'] != null
                  ? lists[i].items['products'].length
                  : 0);
              int completedItems = countItems(lists[i].items['products']);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      showList(lists[i].id);
                    },
                    child: ListTile(
                      tileColor: Colors.black26,
                      title: Text(
                        lists[i].name,
                      ),
                      subtitle: Text(listCreator),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$completedItems/$totalItems'),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                  LinearProgressIndicator(
                    value: dividerWidth(totalItems, completedItems),
                    color: Colors.green,
                  )
                ],
              );
            },
            itemCount: lists.length,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                showGeneralDialog(
                    context: context,
                    barrierLabel: 'add list',
                    pageBuilder: (_, __, ___) {
                      return ChangeNotifierProvider.value(
                        value: context.watch<Lists>(),
                        child: buildNewList(),
                      );
                    });
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildAvatar(String name, BuildContext context) {
  return Avatar(
    name: name,
    placeholderColors: [
      Theme.of(context).primaryColor,
    ],
    border: Border.all(
      color: Theme.of(context).colorScheme.secondary,
      width: 1,
    ),
    textStyle: const TextStyle(
      fontSize: 20,
    ),
  );
}
