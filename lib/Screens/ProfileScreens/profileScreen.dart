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
  bool visiting = false;
  var user;
  var userData;
  late String username;
  get uid => widget.uid;
  int rating = 0,
      savedNum = 0,
      followingNum = 0,
      followersNum = 0;

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
          child: visiting
              ? Container()
              : Container(
            child: _buildStatline('Saved', savedNum),
          ),
        ),
        imageContainer(
          height: height,
          width: width,
          imageLink: profileImage,
          percent: 0.15,
        ),
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

  Widget _buildTab(String tabText) {
    return Tab(
        child: Text(
          tabText,
          style:
          TextStyle(fontWeight: FontWeight.bold, color: appTheme, fontSize: 15),
        ));
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: !visiting
          ? [
        _buildTab('All posts'),
        _buildTab('Meals'),
        _buildTab('Workouts'),
        _buildTab('Saved'),
      ]
          : [
        _buildTab('All posts'),
        _buildTab('Meals'),
        _buildTab('Workouts'),
      ],
    );
  }

  Widget _buildView(double height, double width) {
    if (userData != null) {
      profileImage = userData?.pictureUrl;
      rating = userData?.rating;
      savedNum = userData?.saved;
      followingNum = userData?.following;
      followersNum = userData?.followers;
      username = userData?.name; 'McLovin';
    }

    return DefaultTabController(
        length: visiting ? 3 : 4,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(username),
              actions: visiting
                  ? []
                  : [
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
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (_) => false);
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
                        top: height * 0.035, bottom: height * 0.008),
                    child: _buildTopDisplayRow(height, width, rating, savedNum,
                        followingNum, followersNum)),
                !visiting
                    ? Container(
                  padding: EdgeInsets.only(bottom: height * 0.008),
                )
                    : ElevatedButton(
                  child: const Text("Follow"),
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xff84C59E),
                      shadowColor: appTheme,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      fixedSize: Size(width * 0.25, height * 0.03),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      )),
                  onPressed: () async {
                    const snackBar =
                    SnackBar(content: Text('Feature coming soon'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    children: !visiting
                        ? [
                      FirstTab(),
                      SecondTab(),
                      ThirdTab(),
                      FourthTab(),
                    ]
                        : [
                      FirstTab(),
                      SecondTab(),
                      ThirdTab(),
                    ],
                  ),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    user = Provider.of<AuthRepository>(context);

    if (uid != null) {
      if (user.isAuthenticated && user.getCurrUid() == uid) {
        userData = user.userData;
        visiting = false;
      } else {
        visiting = true;
      }
    } else if (user.isAuthenticated) {
      userData = user.userData;
    } else {
      userData = null;
    }

    if (userData != null) {
      profileImage = userData?.pictureUrl;
      rating = userData?.rating;
      savedNum = userData?.saved;
      followingNum = userData?.following;
      followersNum = userData?.followers;
    }

    if (visiting) {
      return FutureBuilder(
        future: FirebaseDB().getUserModel(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(),);
          }
          if (snapshot.hasError) {
            Navigator.pop(context);
            const snackBar =
            SnackBar(content: Text('Something went wrong'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          userData = snapshot.data;
          return _buildView(height,width);
        },);
    }

    return _buildView(height,width);
  }
}
