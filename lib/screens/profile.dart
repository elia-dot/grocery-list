import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avatars/avatars.dart';
import 'package:grocery_list/models/user.dart';
import 'package:provider/provider.dart';

import 'package:grocery_list/providers/auth.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var profileUser;
  var allowAdding = false;
  Map<String, bool> notifications = {'itemAdded': true, 'addedToList': true};
  bool isNotificationsExpanded = false;
  bool isSettingsExpanded = false;

  var isNameEditable = false;
  var isPhoneEditable = false;

  var initialName = '';
  var initialPhone = '';

  var errorText = '';

  var nameController;
  var phoneController;

  FocusNode nameNode = FocusNode();
  FocusNode phoneNode = FocusNode();

  Future<AppUser?> getUser() async {
    AppUser? user = await Provider.of<Auth>(context, listen: false)
        .getUser(auth.currentUser!.uid);
    profileUser = user;
    if (user != null) {
      setState(() {
        allowAdding = user.allowAdding;
        notifications['addedToList'] = user.allowNotifications['addedToList'];
        notifications['itemAdded'] = user.allowNotifications['itemAdded'];
      });
      initialName = auth.currentUser!.displayName!;
      initialPhone = profileUser.phone;
      nameController = TextEditingController(text: initialName);
      phoneController = TextEditingController(text: initialPhone);
    }
    return user;
  }

  @override
  void initState() {
    getUser();
    phoneNode.addListener(() {
      if (phoneNode.hasFocus) {
        setState(() {
          errorText = '';
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    nameNode.dispose();
    phoneNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Avatar(
              name: initialName,
              placeholderColors: [
                Theme.of(context).primaryColor,
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 3,
              ),
              textStyle: const TextStyle(
                fontSize: 50,
              ),
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          ExpansionPanelList(
            elevation: 0,
            expansionCallback: (_, isExpanded) {
              setState(() {
                isSettingsExpanded = !isSettingsExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'הגדרות פרופיל',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('שם משתמש'),
                      trailing: !isNameEditable
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isNameEditable = true;
                                    });
                                    nameNode.requestFocus();
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                Text(initialName),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => setState(() {
                                    isNameEditable = false;
                                  }),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isNameEditable = false;
                                      initialName = nameController.text;
                                    });
                                    Provider.of<Auth>(context, listen: false)
                                        .updateSettings(
                                      'name',
                                      nameController.text,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    decoration: const InputDecoration(
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
                                    ),
                                    controller: nameController,
                                    focusNode: nameNode,
                                    onSubmitted: (value) => setState(() {
                                      initialName = value;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    ListTile(
                      title: const Text('טלפון'),
                      trailing: !isPhoneEditable
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPhoneEditable = true;
                                    });
                                    phoneNode.requestFocus();
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                Text(initialPhone),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => setState(() {
                                    isPhoneEditable = false;
                                  }),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (phoneController.text.contains('-') ||
                                        phoneController.text.contains(',') ||
                                        phoneController.text.contains('.')) {
                                      setState(() {
                                        errorText = 'נא הכנס מספרים בלבד';
                                      });
                                    } else {
                                      setState(() {
                                        isPhoneEditable = false;
                                        initialPhone = phoneController.text;
                                      });
                                      Provider.of<Auth>(context, listen: false)
                                          .updateSettings(
                                        'phone',
                                        phoneController.text,
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      errorText:
                                          errorText != '' ? errorText : null,
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    controller: phoneController,
                                    focusNode: phoneNode,
                                    onSubmitted: (value) => setState(() {
                                      initialPhone = value;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    ListTile(
                      title: Center(
                        child: ElevatedButton(
                          onPressed: () => auth.signOut(),
                          child: const Text('התנתק'),
                        ),
                      ),
                    )
                  ],
                ),
                isExpanded: isSettingsExpanded,
                canTapOnHeader: true,
              )
            ],
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(
            height: 40,
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SwitchListTile.adaptive(
            value: allowAdding,
            title: const Text('אפשר לצרף אותי לרשימות'),
            activeTrackColor: Colors.green,
            onChanged: (value) {
              setState(() {
                allowAdding = value;
              });
            },
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          ExpansionPanelList(
            elevation: 0,
            expansionCallback: (_, isExpanded) {
              setState(() {
                isNotificationsExpanded = !isNotificationsExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'התראות',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                body: ListView(
                  shrinkWrap: true,
                  children: [
                    SwitchListTile.adaptive(
                      value: notifications['addedToList']!,
                      title: const Text('הוספה לרשימה חדשה'),
                      activeTrackColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          notifications['addedToList'] = value;
                        });
                        Provider.of<Auth>(context, listen: false)
                            .updateNotifications('addedToList', value);
                      },
                    ),
                    SwitchListTile.adaptive(
                      value: notifications['itemAdded']!,
                      title: const Text('הוספת מוצר לרשימה'),
                      activeTrackColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          notifications['itemAdded'] = value;
                        });
                        Provider.of<Auth>(context, listen: false)
                            .updateNotifications('itemAdded', value);
                      },
                    ),
                  ],
                ),
                isExpanded: isNotificationsExpanded,
                canTapOnHeader: true,
              )
            ],
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
