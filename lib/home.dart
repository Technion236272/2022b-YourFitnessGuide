import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/constants.dart';
import 'package:yourfitnessguide/utils/users.dart';

import 'Screens/searchScreen.dart';
import 'Screens/notificationsScreen.dart';
import 'Screens/signinScreen.dart';
import 'Screens/signupScreen.dart';
import 'Screens/timelineScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final appTheme = const Color(0xff4CC47C);
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const TimelineScreen(),
    const SearchScreen(),
    const NotificationsScreen(),
    const LoginScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text('YourFitnessGuide'), centerTitle: true),
        body: IndexedStack(
          children: _views,
          index: _selectedIndex,
        ),
        bottomNavigationBar: BottomNavigationBar(
          //fixedColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile')
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).iconTheme.color,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped
        ));
  }
}
