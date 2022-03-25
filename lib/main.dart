import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/providers/lists.dart';
import '/providers/auth.dart';
import '/screens/signup_screen.dart';
import '/screens/login_screen.dart';
import '/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => MyApp(), // Wrap your app
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => Lists(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                Color.fromARGB(255, 1, 45, 112),
                Colors.redAccent,
              ],
              stops: [0.7, 0.95],
            ),
          ),
          child: MaterialApp(
            useInheritedMediaQuery: true,
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            title: 'רשימת קניות',
            theme: ThemeData(
              primaryColor: const Color.fromARGB(255, 1, 45, 112),
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: Colors.redAccent),
              scaffoldBackgroundColor: Colors.transparent,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              cardColor: Colors.transparent,
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            ),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Home().getLandingPage(context),
            ),
            routes: {
              SignupScreen.routeName: (ctx) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: SignupScreen(),
                  ),
              LoginScreen.routeName: (ctx) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: LoginScreen(),
                  ),
              HomeScreen.routeName: (ctx) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: HomeScreen(),
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
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        });
  }
}
