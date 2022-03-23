import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_list/providers/auth.dart';
import 'package:grocery_list/widget/add_user.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';

import '/providers/product.dart';
import '/screens/list_products.dart';
import '/providers/list.dart';
import '/providers/lists.dart';
import '/helpers/avatar.dart';

class ListsScreen extends StatefulWidget {
   const ListsScreen({Key? key}) : super(key: key);

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, dynamic> listData = {
    'name': '',
    'createdBy': {},
    'updatedAt': '',
    'createdAt': '',
    'items': {'completed': false, 'itemsList': <Product>[]},
  };
  var _isLoading = false;

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

  @override
  void initState() {
    final listsProvider = Provider.of<Lists>(context, listen: false);
    final authProvider = Provider.of<Auth>(context, listen: false);
    authProvider.setAuthUser();
    listsProvider.listsListener();
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

  List<Widget> participants(_setState) {
    var listsProvider = Provider.of<Lists>(context);
    var users = listsProvider.listUsers;
    List<Widget> res = users.map((e) {
      return SizedBox(
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            listsProvider.removeUser(e);
            _setState(() {});
          },
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
            child: buildAvatar(e.name, context),
          ),
        ),
      );
    }).toList();
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
                    return AddUser(func: 'new');
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
      builder: (context, _setState) => Scaffold(
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
                            children: participants(_setState),
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
    final listsPeovider = Provider.of<Lists>(context);
    List<ShopingList> lists = listsPeovider.lists;
    return Scaffold(
      body: Column(
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
          if (listsPeovider.isFetchingLists)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          if (!listsPeovider.isFetchingLists)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (ctx, i) {
                  String partCount =
                      '${lists[i].participants.length + 1} משתתפים';
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
                          subtitle: lists[i].participants.isNotEmpty
                              ? Text(partCount)
                              : null,
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
          if (!listsPeovider.isFetchingLists && lists.isEmpty)
            const Expanded(
              child: Text('אין רשימות להצגה'),
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
      ),
    );
  }
}
