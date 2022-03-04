import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';


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