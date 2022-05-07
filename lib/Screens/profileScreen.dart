import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_1.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_2.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_3.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profiletab_4.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/constants.dart';
import 'dart:io';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? profileImage;
  final appTheme = const Color(0xff4CC47C);

  Widget _buildImageContainer(double height, double width) {
    return Container(
        width: height * 0.15,
        height: height * 0.15,
        decoration: BoxDecoration(
            border:
            Border.all(width: 4, color: Color(0xffD6D6D6)),
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
                    fit: BoxFit.cover,
                    image: Image.file(profileImage!).image)));
  }

  Widget _buildStatline(String stat, int value) {
    return Center(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            stat,
            style: TextStyle(color: Colors.grey, fontSize: 14),
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

  Widget _buildTabBar(){
    return TabBar(
      tabs: [
        Tab(
          child: Text(
            'All posts',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme,fontSize: 15),
          ),
        ),
        Tab(
          child: Text(
            'Meals',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme,fontSize: 15),
          ),
        ),
        Tab(
          child: Text(
            'Workouts',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme,fontSize: 15),
          ),
        ),
        Tab(
          child: Text(
            'Saved',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: appTheme,fontSize: 15),
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
    final String userName = 'McLovin';
    final rating = 1;
    final savedNum = 2;
    final followingNum = 3;
    final followersNum = 4;
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
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            )),
                        IconButton(
                            onPressed: () {
                              user.signOut();
                              Navigator.pushReplacementNamed(context, homeRoute);
                            },
                            icon: Icon(
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
