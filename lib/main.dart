import 'package:flutter/material.dart';

import '/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Colors.indigo,
            Colors.redAccent,
          ],
          stops: [0.5, 1],
        ),
      ),
      child: MaterialApp(
        title: 'רשימת קניות',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.redAccent,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: LoginScreen(),
        ),
        routes: {
          
        },
      ),
    );
  }
}
