import 'package:flutter/material.dart';
import 'package:grocery_list/screens/lists.dart';
import 'package:grocery_list/screens/profile.dart';
import 'package:grocery_list/screens/recommendation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screenOptions = [
      Directionality(textDirection: TextDirection.rtl, child: Profile()),
      Directionality(textDirection: TextDirection.rtl, child: ListsScreen()),
      const Directionality(
          textDirection: TextDirection.rtl, child: Recommendations()),
    ];
    return Scaffold(
      appBar: AppBar(),
      body: _screenOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white,
        selectedFontSize: 18,
        elevation: 16,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'פרופיל',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'רשימות קניה',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'המלצות',
            tooltip: '',
          ),
        ],
      ),
    );
  }
}
