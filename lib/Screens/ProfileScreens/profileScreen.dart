import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
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
  String? currUid;
  bool visiting = false;
  var user;
  var userData;
  String username = '';
  var posts;
  var posts2;
  ListView? postsCards = null;
  ListView? meals = null;
  ListView? workouts = null;
  bool noPosts = false;
  List<String>? savedPosts = null;

  get uid => widget.uid;
  int rating = 0, savedNum = 0, followingNum = 0, followersNum = 0;

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

  Widget _buildTabHeader(String tabText) {
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
              _buildTabHeader('All posts'),
              _buildTabHeader('Meals'),
              _buildTabHeader('Workouts'),
              _buildTabHeader('Saved'),
            ]
          : [
              _buildTabHeader('All posts'),
              _buildTabHeader('Meals'),
              _buildTabHeader('Workouts'),
            ],
    );
  }

  Widget emptyNote(double height, double width, String text) {
    return Card(
        color: Colors.grey[200],
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: height * 0.01,
            ),
            Flexible(
                child: Text(
              text,
              style: TextStyle(fontSize: 20),
            )),
            Flexible(
                child: Image.asset(
              'images/decorations/404.png',
              width: width * 0.3,
              height: height * 0.3,
            ))
          ],
        )));
    return Image.asset(
      'images/decorations/LoginDecoration.png',
      width: width * 0.01,
      height: height * 0.01,
    );
  }

  Widget _buildView(double height, double width) {
    if (userData != null) {
      profileImage = userData?.pictureUrl;
      rating = 0;
      followingNum = 0;
      followersNum = 0;
      username = userData?.name ?? 'Mclovin';
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
                                    setState(() {});
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
                            side: BorderSide(
                                width: 2.0,
                                color: Colors.black.withOpacity(0.5)),
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
                SizedBox(
                  height: height * 0.005,
                ),
                Flexible(
                  child: TabBarView(
                    children: !visiting
                        ? (noPosts
                            ? [
                                emptyNote(height, width,
                                    'You haven\'t published a post yet'),
                                emptyNote(height, width,
                                    'You haven\'t published a post yet'),
                                emptyNote(height, width,
                                    'You haven\'t published a post yet'),
                                savedNum == 0
                                    ? emptyNote(height, width,
                                        'You haven\'t saved a post yet')
                                    : (_buildSaved()),
                              ]
                            : [
                                _buildTab(),
                                _buildTab(category: "Meal Plan"),
                                _buildTab(category: "Workout"),
                                savedNum == 0
                                    ? emptyNote(height, width,
                                        'You haven\'t saved a post yet')
                                    : (_buildSaved()),
                              ])
                        : (noPosts
                            ? [
                                emptyNote(height, width,
                                    'User hasn\'t published a post yet'),
                                emptyNote(height, width,
                                    'User hasn\'t published a post yet'),
                                emptyNote(height, width,
                                    'User hasn\'t published a post yet'),
                              ]
                            : [
                                _buildTab(),
                                _buildTab(category: "Meal Plan"),
                                _buildTab(category: "Workout"),
                              ]),
                  ),
                ),
              ],
            )));
  }

  ListView _buildTab({String? category}) {
    var tmp = ListView.builder(
      //separatorBuilder: (context, index) => const Divider(),
      itemCount: posts.data == null ? 0 : posts.data!.docs.length,
      itemBuilder: (context, index) {
        if (posts.connectionState == ConnectionState.waiting &&
            posts.data == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (posts.connectionState == ConnectionState.done &&
            posts.data == null) {
          return const Center(child: Text('No data available'));
        }
        if (category != null) {
          var currCat = posts?.data!.docs[index].data()!['category'];
          if (currCat != category) {
            return Container();
          }
          return post(
            snapshot: posts,
            index: index,
            screen: visiting ? 'timeline' : 'profile',
          );
        }
        return post(
          snapshot: posts,
          index: index,
          screen: visiting ? 'timeline' : 'profile',
        );
      },
    );

    if (category == null) {
      postsCards = tmp;
      return postsCards!;
    }
    if (category == "Meal Plan") {
      meals = tmp;
      return meals!;
    } else {
      workouts = tmp;
      return workouts!;
    }
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>?>> _buildSaved(
      {String? category}) {
    int counter = 0;
    return StreamBuilder(
      stream: PostManager().getAllPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(username),
            ),
            body: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (snapshot.hasError) {
          Navigator.pop(context);
          const snackBar = SnackBar(content: Text('Something went wrong'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        posts2 = snapshot;

        return ListView.builder(
            itemCount: posts2.data == null ? 0 : posts2.data!.docs.length,
            itemBuilder: (context, index) {
              var currPost = posts2?.data!.docs[index].id;
              if (savedPosts!.contains(currPost)) {
                return post(
                  snapshot: posts2,
                  index: index,
                  screen: visiting ? 'timeline' : 'profile',
                );
              } else {
                return Container();
              }
            });
      },
    );
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
        currUid = uid;
      } else {
        visiting = true;
        currUid = uid;
      }
    } else if (user.isAuthenticated) {
      userData = user.userData;
      currUid = uid;
    } else {
      userData = null;
    }

    if (userData != null) {
      user.updateSaved();
      profileImage = userData?.pictureUrl;
      rating = userData?.rating;
      savedNum = userData?.saved;
      followingNum = userData?.following;
      followersNum = userData?.followers;
      currUid = uid ?? user.getCurrUid();
      username = userData?.name ?? 'Mclovin';
      savedPosts = userData?.savedPosts;
    }

    return FutureBuilder(
      future: FirebaseDB().getUserModel(currUid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          Navigator.pop(context);
          const snackBar = SnackBar(content: Text('Something went wrong'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        userData = snapshot.data;

        return StreamBuilder(
          stream: PostManager().getUserPosts(uid),
          builder: (context, snapshot2) {
            if (!snapshot2.hasData) {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(username),
                ),
                body: const Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            if (snapshot2.hasError) {
              Navigator.pop(context);
              const snackBar = SnackBar(content: Text('Something went wrong'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            posts = snapshot2;
            if (posts.data!.docs.length == 0) {
              noPosts = true;
            }
            return _buildView(height, width);
          },
        );
      },
    );
  }
}
