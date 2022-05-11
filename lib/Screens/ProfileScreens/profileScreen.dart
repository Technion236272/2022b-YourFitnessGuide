import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_1.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_2.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_3.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_4.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/globals.dart';

class ProfileScreen extends StatefulWidget {
  late String? uid;

  ProfileScreen({Key? key, this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImage;

  get uid => widget.uid;

  Widget _buildImageContainer(double height, double width) {
    return Container(
        width: height * 0.15,
        height: height * 0.15,
        decoration: BoxDecoration(
            border: Border.all(width: 4, color: const Color(0xffD6D6D6)),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 3,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1))
            ],
            shape: BoxShape.circle,
            image: profileImage == null
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset('images/decorations/mclovin.png').image)
                : DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(profileImage!))));
  }

  Widget _buildStatline(String stat, int value) {
    return Center(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            stat,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          )
        ],
      ),
    );
  }

  Widget _buildTopDisplayRow(double height, double width, int rating,
      int savedNum, int followingNum, int followersNum) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildStatline('Rating', rating),
          ),
        ),
        Expanded(
          child: Container(
            child: _buildStatline('Saved', savedNum),
          ),
        ),
        _buildImageContainer(height, width),
        Expanded(
          child: Container(
            child: _buildStatline('Following', followingNum),
          ),
        ),
        Expanded(
          child: Container(
            child: _buildStatline('Followers', followersNum),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: [
        Tab(
          child: Text(
            'All posts',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme, fontSize: 15),
          ),
        ),
        Tab(
          child: Text(
            'Meals',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme, fontSize: 15),
          ),
        ),
        Tab(
          child: Text(
            'Workouts',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme, fontSize: 15),
          ),
        ),
        Tab(
          child: Text(
            'Saved',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme, fontSize: 15),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    var user = Provider.of<AuthRepository>(context);
    var userData;

    if (uid != null) {
      userData = FirebaseDB().getUserInfo(uid);
    } else if (user.isAuthenticated) {
      userData = user.userData;
      profileImage = userData?.pictureUrl;
    } else {
      userData = null;
    }
    final String userName = userData?.name ?? 'McLovin';
    const rating = 1;
    const savedNum = 2;
    const followingNum = 3;
    const followersNum = 4;
    return DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(userName),
              actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit');
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            )),
                        IconButton(
                            onPressed: () {
                              user.signOut();
                              Navigator.pushReplacementNamed(
                                  context, homeRoute);
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ))
                      ],
                    )),
              ],
            ),
            body: Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: height * 0.035, bottom: height * 0.14),
                    child: _buildTopDisplayRow(height, width, rating, savedNum,
                        followingNum, followersNum)),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      FirstTab(),
                      SecondTab(),
                      ThirdTab(),
                      FourthTab(),
                    ],
                  ),
                ),
              ],
            )));
  }
}
