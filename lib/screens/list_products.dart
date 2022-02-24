import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    'addedby': {},
    'completed': false
  };
  int _value = 0;
  var _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
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
          body: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextField(
                              controller: nameController,
                              focusNode: nameNode,
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
                              onChanged: (String value) {
                                setState(() {
                                  productData['name'] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
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
                          Padding(
                            padding: const EdgeInsets.only(top: 27),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                dropdownColor: Theme.of(context).primaryColor,
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
                          )
                        ],
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.secondary),
                        ),
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
                Expanded(
                  child: list.items['products'] == null ||
                          list.items['products'].isEmpty
                      ? const Center(
                          child: Text('רשימת הקניות שלך ריקה'),
                        )
                      : Container(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (ctx, i) => ListTile(
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
                              trailing: Text(list.items['products'][i].amount),
                            ),
                            itemCount: list.items['products'].length,
                          ),
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
