import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_1.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_2.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_3.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_4.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class ProfileScreen extends StatefulWidget {
  late String? uid;

  ProfileScreen({Key? key, this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImage;

  get uid => widget.uid;

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
        imageContainer(height: height,width: width, imageLink: profileImage, percent: 0.15,),
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

  Widget _buildTab(String tabText){
    return Tab(
        child: Text(
        tabText,
        style: TextStyle(
        fontWeight: FontWeight.bold, color: appTheme, fontSize: 15),
    ));
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: [ _buildTab('All posts'),
        _buildTab('Meals'),
        _buildTab('Workouts'),
        _buildTab('Saved'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    var user = Provider.of<AuthRepository>(context);
    var userData;
    int rating = 0;
    int savedNum = 0;
    int followingNum = 0;
    int followersNum = 0;

    if (uid != null) {
      userData = FirebaseDB().getUserInfo(uid);
    } else if (user.isAuthenticated) {
      userData = user.userData;
      profileImage = userData?.pictureUrl;
      rating = userData?.rating;
      savedNum = userData?.saved;
      followingNum = userData?.following;
      followersNum = userData?.followers;
    } else {
      userData = null;
    }
    final String userName = userData?.name ?? 'McLovin';

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
