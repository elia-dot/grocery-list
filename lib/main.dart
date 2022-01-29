import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grocery_list/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/providers/auth.dart';
import '/screens/signup_screen.dart';
import '/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => Container(
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
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Colors.redAccent),
              scaffoldBackgroundColor: Colors.transparent,
            ),
            home: Directionality(
                textDirection: TextDirection.rtl,
                child: Home().getLandingPage(context)),
            routes: {
              SignupScreen.routeName: (ctx) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: SignupScreen(),
                  ),
              LoginScreen.routeName: (ctx) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: LoginScreen(),
                  ),
            },
          ),
        ),
      ),
    );
  }
}

class Home {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget getLandingPage(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        });
  }
}
