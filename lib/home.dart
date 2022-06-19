import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'Screens/ProfileScreens/editProfileScreen.dart';
import 'Screens/ProfileScreens/profileScreen.dart';
import 'Screens/leaderboardScreen.dart';
import 'Screens/searchScreen.dart';
import 'Screens/notificationsScreen.dart';
import 'Screens/AuthenticationScreens/signinScreen.dart';
import 'Screens/timelineScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    TimelineScreen(),
    const SearchScreen(),
    const LeaderboardScreen(),
    /*const NotificationsScreen(),*/
    const LoginScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthRepository>(context);

    /// Removing last to get relevant screen:
    /// Profile, Edit Profile or Login
    _views.removeLast();
    if (user.isAuthenticated && (user.userData?.iWeight != 0)) {
      _views.add(ProfileScreen(uid: user.uid));
    } else {
      if (user.isAuthenticated) {
        _views.add(EditProfileScreen(firstTime: true));
      } else {
        _views.add(const LoginScreen());
      }
    }

    return Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _views),
        bottomNavigationBar:
          BottomNavigationBar(
            //type: BottomNavigationBarType.fixed,
            //fixedColor: Colors.black,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
              /*BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),*/
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).iconTheme.color,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            onTap: _onItemTapped
        )
    );
  }
}
