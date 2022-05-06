import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/helpers/avatar.dart';
import '/widget/add_user.dart';
import '/providers/list.dart';
import '/providers/lists.dart';

class ListProducts extends StatefulWidget {
  final String listId;
  const ListProducts({
    Key? key,
    required this.listId,
  }) : super(key: key);

  @override
  _ListProductsState createState() => _ListProductsState();
}

class _ListProductsState extends State<ListProducts> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, dynamic> productData = {
    'name': '',
    'amount': '',
    'category': 'כללי',
    'addedby': {},
    'completed': false
  };
  int _value = 0;
  var _isLoading = false;
  var _isExpanded = false;
  var isFormVisible = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  FocusNode nameNode = FocusNode();

  Future<void> add() async {
    productData['addedby']['name'] = auth.currentUser!.displayName;
    productData['addedby']['id'] = auth.currentUser!.uid;
    productData['amount'] = _value == 0
        ? "${productData['amount']} יחי'"
        : '${productData['amount']} ק"ג';
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Lists>(context, listen: false)
        .addItem(widget.listId, productData);
    nameController.clear();
    amountController.clear();
    setState(() {
      productData = {
        'name': '',
        'amount': '',
        'addedby': {},
        'completed': false
      };
      _value = 0;
      _isLoading = false;
    });
    nameNode.requestFocus();
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    nameNode.dispose();
    super.dispose();
  }

  int countParticipants(List participants) {
    int count = 0;
    for (int i = 0; i < participants.length; i++) {
      if (participants[i]['active']) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    var listProvider = Provider.of<Lists>(context);
    ShopingList list = listProvider.getList(widget.listId);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(list.name),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() {
              isFormVisible = !isFormVisible;
            }),
            child: Icon(isFormVisible ? Icons.close : Icons.add),
          ),
          body: Container(
            color: Theme.of(context).primaryColor,
            child: ListView(
              children: [
                if (isFormVisible)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: TextField(
                                    controller: nameController,
                                    focusNode: nameNode,
                                    decoration: const InputDecoration(
                                      labelText: 'שם המוצר:',
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
                                    onChanged: (String value) {
                                      setState(() {
                                        productData['name'] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: amountController,
                                    decoration: const InputDecoration(
                                      labelText: 'כמות:',
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
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        productData['amount'] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 27),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      dropdownColor:
                                          Theme.of(context).primaryColor,
                                      elevation: 3,
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                      value: _value,
                                      items: const [
                                        DropdownMenuItem(
                                          child: Text(
                                            'יחידות',
                                          ),
                                          value: 0,
                                        ),
                                        DropdownMenuItem(
                                          child: Text(
                                            'ק"ג',
                                          ),
                                          value: 1,
                                        ),
                                      ],
                                      onChanged: (int? value) {
                                        setState(() {
                                          _value = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ||
                                  productData['name'] == '' ||
                                  productData['amount'] == ''
                              ? () {}
                              : () {
                                  add();
                                },
                          child: const Text('הוסף'),
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionPanelList(
                    elevation: 0,
                    expansionCallback: (_, isExpanded) {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'משתתפים:',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        },
                        body: Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: buildAvatar(
                                        list.createdBy['name'], context),
                                  ),
                                  title: Text(list.createdBy['name']),
                                  subtitle: const Text('מנהל הרשימה'),
                                ),
                                for (int i = 0;
                                    i < list.participants.length;
                                    i++)
                                  if (list.participants[i]['active'])
                                    ListTile(
                                      leading: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: buildAvatar(
                                            list.participants[i]['name'],
                                            context),
                                      ),
                                      title: Text(list.participants[i]['name']),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (countParticipants(
                                                    list.participants) ==
                                                0) {
                                              listProvider.deleteList(list.id);
                                            } else {
                                              listProvider.leaveList(list.id,
                                                  auth.currentUser!.uid);
                                            }
                                          },
                                          child: Text(
                                            countParticipants(
                                                        list.participants) ==
                                                    0
                                                ? 'מחק רשימה'
                                                : 'צא מהרשימה',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AddUser(
                                                    func: 'update',
                                                    listId: list.id,
                                                  );
                                                });
                                          },
                                          child: const Text(' הוסף משתמש'),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        isExpanded: _isExpanded,
                        canTapOnHeader: true,
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),
                list.items['products'] == null || list.items['products'].isEmpty
                    ? const Center(
                        child: Text('רשימת הקניות ריקה'),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0;
                                i < list.items['products'].length;
                                i++)
                              Dismissible(
                                key: Key(list.items['products'][i].id),
                                onDismissed: (direction) {
                                  listProvider.removeItem(
                                      list.items['products'][i].id, list.id);
                                },
                                background: Container(
                                  color: Colors.red,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        Expanded(child: Container()),
                                        Icon(
                                          Icons.delete,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: GestureDetector(
                                    onTap: () {
                                      listProvider.checkItem(
                                          list.items['products'][i].id,
                                          widget.listId,
                                          !list.items['products'][i].completed);
                                    },
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: list.items['products'][i].completed
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                  title: Text(list.items['products'][i].name),
                                  trailing:
                                      Text(list.items['products'][i].amount),
                                ),
                              ),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
