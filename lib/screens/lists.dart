import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_list/models/user.dart';
import 'package:grocery_list/providers/auth.dart';
import 'package:grocery_list/providers/product.dart';
import 'package:provider/provider.dart';

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
  var _isExpanded = false;

  String searchTerm = '';
  var users = [];

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

  Widget usersSuggestion() {
    print(users);
    var authProvider = Provider.of<Auth>(context, listen: false);
    var suggestions = authProvider.suggestionsList;
    var res = Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
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
                        decoration: const InputDecoration(
                          hintText: "הכנס מס' טלפון או שם",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          authProvider.searchUser(value);
                        },
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
            ),
            if (searchTerm == '' && authUser.friends.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, i) => InkWell(
                  onTap: () {
                    setState(() {
                      users.add(authUser.friends[i]);
                    });
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    title: Text(authUser.friends[i]['name']),
                    trailing: SizedBox(
                      width: 40,
                      height: 40,
                      child: buildAvatar(authUser.friends[i]['name'], context),
                    ),
                  ),
                ),
                itemCount: authUser.friends.length,
              ),
            if (suggestions.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, i) => InkWell(
                  onTap: () {
                    setState(() {
                      users.add(suggestions[i]);
                    });
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
                ),
                itemCount: suggestions.length,
              )
          ],
        ),
      ),
    );

    return res;
  }

  List<Widget> participants() {
    return users
        .map(
          (e) => SizedBox(
            width: 40,
            height: 40,
            child: buildAvatar(e['name'], context),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                      return StatefulBuilder(
                        builder: (context, setState) => Scaffold(
                          appBar: AppBar(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          body: GestureDetector(
                            onTap: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                height: size.height,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(26.0),
                                          child: Text(
                                            'רשימה חדשה',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
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
                                        Stack(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('משתתפים:'),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Wrap(
                                                    children: participants(),
                                                  )
                                                ],
                                              ),
                                            ),
                                            ExpansionPanelList(
                                              elevation: 0,
                                              expansionCallback:
                                                  (_, isExpanded) {
                                                setState(() {
                                                  _isExpanded = !_isExpanded;
                                                });
                                              },
                                              children: [
                                                ExpansionPanel(
                                                  headerBuilder:
                                                      (context, isExpanded) {
                                                    return const Padding(
                                                      padding:
                                                          EdgeInsets.all(12.0),
                                                      child: Text(
                                                        'הוסף',
                                                        style: TextStyle(
                                                            fontSize: 17),
                                                      ),
                                                    );
                                                  },
                                                  body: usersSuggestion(),
                                                  isExpanded: _isExpanded,
                                                  canTapOnHeader: true,
                                                )
                                              ],
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              child: Align(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    submit();
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'יצירת רשימה',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      if (_isLoading)
                                                        const SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              },
              child: Icon(Icons.add),
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
