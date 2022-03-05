import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avatars/avatars.dart';
import 'package:grocery_list/helpers/avatar.dart';
import 'package:grocery_list/models/friend.dart';
import 'package:grocery_list/models/user.dart';
import 'package:grocery_list/widget/add_user.dart';
import 'package:provider/provider.dart';

import 'package:grocery_list/providers/auth.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var allowAdding;
  bool isNotificationsExpanded = false;
  bool isSettingsExpanded = false;
  bool isFriendsExpanded = false;
  bool isRequestsExpanded = false;

  var isNameEditable = false;
  var isPhoneEditable = false;

  var initialName = '';
  var initialPhone = '';

  Map notification = {};

  var errorText = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  FocusNode nameNode = FocusNode();
  FocusNode phoneNode = FocusNode();

  @override
  void initState() {
    final authProvider = Provider.of<Auth>(context, listen: false);
    initialName = authProvider.authUser.name;
    initialPhone = authProvider.authUser.phone;
    notification = authProvider.authUser.allowNotifications;
    allowAdding = authProvider.authUser.allowAdding;
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
    nameNode.dispose();
    phoneNode.dispose();
    super.dispose();
  }

  Widget friendsList(BuildContext context, AppUser authUser) {
    List<Widget> res = [];
    for (Friend friend in authUser.friends) {
      Widget tile = Dismissible(
        key: Key(friend.name),
        onDismissed: (direction) {
          Provider.of<Auth>(context, listen: false).removeFriend(friend.id);
        },
        background: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          leading: friend.confirmed
              ? null
              : TextButton(
                  onPressed: () {
                    Provider.of<Auth>(context, listen: false).resendReq(friend);
                  },
                  child: const Text('שלח שוב'),
                ),
          title: Text(friend.name),
          subtitle: friend.confirmed
              ? Text(friend.phone)
              : const Text('ממתין לאישור'),
          trailing: SizedBox(
            width: 45,
            height: 45,
            child: buildAvatar(friend.name, context),
          ),
        ),
      );
      res.add(tile);
    }
    res.add(ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AddUser(
                  func: 'friends',
                );
              });
        },
        child: const Text('הוסף חברים')));
    return Column(
      children: res,
    );
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<Auth>(context);
    AppUser authUser = authProvider.authUser;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Avatar(
              name: authUser.name,
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
                      'פרטי פרופיל',
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
          SwitchListTile.adaptive(
            value: allowAdding,
            title: const Text('אפשר לצרף אותי לרשימות'),
            activeTrackColor: Colors.green,
            onChanged: (value) {
              setState(() {
                allowAdding = !allowAdding;
              });
              authProvider.updateSettings('allowAdding', value);
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
                      value: notification['addedToList'],
                      title: const Text('הוספה לרשימה חדשה'),
                      activeTrackColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          notification['addedToList'] =
                              !notification['addedToList'];
                        });
                        authProvider.updateNotifications('addedToList', value);
                      },
                    ),
                    SwitchListTile.adaptive(
                      value: notification['itemAdded'],
                      title: const Text('הוספת מוצר לרשימה'),
                      activeTrackColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          notification['itemAdded'] =
                              !notification['itemAdded'];
                        });
                        authProvider.updateNotifications('itemAdded', value);
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
          ExpansionPanelList(
            elevation: 0,
            expansionCallback: (_, isExpanded) {
              setState(() {
                isFriendsExpanded = !isFriendsExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'חברים',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
                body: friendsList(context, authUser),
                isExpanded: isFriendsExpanded,
                canTapOnHeader: true,
              )
            ],
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.secondary,
          ),
          if (authUser.requests.isNotEmpty)
            ExpansionPanelList(
              elevation: 0,
              expansionCallback: (_, isExpanded) {
                setState(() {
                  isRequestsExpanded = !isRequestsExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text('${authUser.requests.length}'),
                            ),
                          ),
                          const Text(
                            'בקשות',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                  body: ListView.builder(
                      shrinkWrap: true,
                      itemCount: authUser.requests.length,
                      itemBuilder: (ctx, i) {
                        return ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  authProvider.deleteRequest(
                                      authUser.requests[i]['id']);
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  authProvider
                                      .confirmRequest(authUser.requests[i]);
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          title: Text(authUser.requests[i]['name']),
                          trailing: SizedBox(
                            width: 45,
                            height: 45,
                            child: buildAvatar(
                                authUser.requests[i]['name'], context),
                          ),
                        );
                      }),
                  isExpanded: isRequestsExpanded,
                  canTapOnHeader: true,
                )
              ],
            ),
          if (authUser.requests.isNotEmpty)
            Divider(
              thickness: 0.5,
              color: Theme.of(context).colorScheme.secondary,
            ),
        ],
      ),
    );
  }
}
