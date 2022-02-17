import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '/providers/list.dart';
import '/providers/lists.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, String> listData = {
    'name': '',
    'description': '',
    'createdBy': '',
    'updatedAt': '',
    'createdAt': ''
  };
  var _isLoading = false;

  Future<void> submit() async {
    final listsProvider = Provider.of<Lists>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    listData['createdBy'] = auth.currentUser!.uid;
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
    listsProvider.listsListener();
    super.initState();
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
        Expanded(
          child: ListView.builder(
            itemBuilder: (ctx, i) {
              return Text(lists[i].name);
            },
            itemCount: lists.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            onPressed: () {
              showGeneralDialog(
                  context: context,
                  barrierLabel: 'add list',
                  pageBuilder: (_, __, ___) {
                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: Theme.of(context).primaryColor,
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
                            color: Theme.of(context).primaryColor,
                            height: size.height,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'תיאור:',
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
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      onChanged: (value) {
                                        setState(() {
                                          listData['description'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        submit();
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'יצירת רשימה',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            },
            label: const Text(
              'צור רשימה חדשה',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
