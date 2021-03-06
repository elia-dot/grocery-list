import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:grocery_list/providers/auth.dart';
import 'package:grocery_list/screens/lists.dart';
import 'package:grocery_list/screens/profile.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedIndex = 0;

  @override
  void initState() {
    final authProvider = Provider.of<Auth>(context, listen: false);
    authProvider.setAuthUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);
    final List<Widget> _screenOptions = [
      const Directionality(
          textDirection: TextDirection.rtl, child: ListsScreen()),
      const Directionality(textDirection: TextDirection.rtl, child: Profile()),
    ];
    return Scaffold(
      appBar: AppBar(),
      body: _screenOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white,
        selectedFontSize: 18,
        elevation: 8,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'רשימות קניה',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              child: const Icon(Icons.person),
              showBadge: authProvider.authUser.requests.isNotEmpty,
            ),
            label: 'פרופיל',
            tooltip: '',
          ),
        ],
      ),
    );
  }
}
