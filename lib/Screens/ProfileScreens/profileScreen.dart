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
  int? followingNum = null, followersNum = null;

  ProfileScreen({Key? key, this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImage;
  var hide = false;
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
  late double height, width;
  String followButtonText = 'Follow';
  bool setup = true;

  get uid => widget.uid;
  int rating = 0, savedNum = 0;

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
            style: const TextStyle(color: appTheme, fontSize: 14),
          )
        ],
      ),
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

  Widget _buildTopDisplayRow(
      double height, double width, int rating, int savedNum) {
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
            child: _buildStatline('Following', widget.followingNum ?? 0),
          ),
        ),
        Expanded(
          child: Container(
            child: _buildStatline('Followers', widget.followersNum ?? 0),
          ),
        ),
      ],
    );
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
    return RefreshIndicator(
        child: Card(
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
            ))),
        onRefresh: () async {
          setState(() {});
        });
  }

  Widget _buildTab({String? category}) {
    bool workoutsFound = false, mealsFound = false;

    for (int i = 0; i < posts.data!.docs.length; i++) {
      if (category != null) {
        if (posts?.data!.docs[i].data()!['category'] == 'Meal Plan') {
          mealsFound = true;
        }
        if (posts?.data!.docs[i].data()!['category'] == 'Workout') {
          workoutsFound = true;
        }
      }
    }

    if (category != null) {
      if (category == 'Meal Plan' && !mealsFound) {
        var pronoun = visiting ? 'User hasn\'t ' : 'You have not ';
        return emptyNote(
            height, width, pronoun + 'published a ' + category + ' yet');
      } else if (category == 'Workout' && !workoutsFound) {
        var pronoun = visiting ? 'User hasn\'t ' : 'You have not ';

        return emptyNote(
            height, width, pronoun + 'published a ' + category + ' yet');
      }
    }

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
      return RefreshIndicator(
          child: postsCards!,
          onRefresh: () async {
            setState(() {});
          });
      return postsCards!;
    }
    if (category == "Meal Plan") {
      meals = tmp;
      return RefreshIndicator(
          child: meals!,
          onRefresh: () async {
            setState(() {});
          });
    } else {
      workouts = tmp;
      return RefreshIndicator(
          child: workouts!,
          onRefresh: () async {
            setState(() {});
          });
    }
  }

  Widget _buildView() {
    if (userData != null) {
      profileImage = userData?.pictureUrl;
      rating = 0;
      username = userData?.name ?? 'Undefined name';
    }
    return DefaultTabController(
        length: visiting ? 3 : 4,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
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
                    child: _buildTopDisplayRow(
                      height,
                      width,
                      rating,
                      savedNum,
                    )),
                !visiting
                    ? Container(
                        padding: EdgeInsets.only(bottom: height * 0.008),
                      )
                    : (ElevatedButton(
                        child: Text(followButtonText),
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xff84C59E),
                            shadowColor: appTheme,
                            side: BorderSide(
                                width: 2.0,
                                color: Colors.black.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            fixedSize: Size(width * 0.32, height * 0.03),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            )),
                        onPressed: () async {
                          if (followButtonText == 'Following') {
                            setState(() {
                              followButtonText = 'Follow';
                              if(widget.followersNum != null){
                                widget.followersNum =widget.followersNum! - 1;
                              }

                              user.modifyFollow(currUid, true);
                            });
                          } else {
                            setState(() {
                              followButtonText = 'Following';
                              if(widget.followersNum != null){
                                widget.followersNum =widget.followersNum! + 1;
                              }
                              user.modifyFollow(currUid, false);
                            });
                          }
                        })),
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
                                    'You have not published a post yet'),
                                emptyNote(height, width,
                                    'You have not published a Meal Plan yet'),
                                emptyNote(height, width,
                                    'You have not published a Workout yet'),
                                savedNum == 0
                                    ? emptyNote(height, width,
                                        'You have not saved a post yet')
                                    : (_buildSaved()),
                              ]
                            : [
                                _buildTab(),
                                _buildTab(category: "Meal Plan"),
                                _buildTab(category: "Workout"),
                                savedNum == 0
                                    ? emptyNote(height, width,
                                        'You have not saved a post yet')
                                    : (_buildSaved()),
                              ])
                        : (noPosts
                            ? [
                                emptyNote(height, width,
                                    'User has not published a post yet'),
                                emptyNote(height, width,
                                    'User has not published a Meal Plan yet'),
                                emptyNote(height, width,
                                    'User has not published a Workout yet'),
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

  StreamBuilder<QuerySnapshot<Map<String, dynamic>?>> _buildSaved(
      {String? category}) {
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
        return RefreshIndicator(
            child: ListView.builder(
                itemCount: posts2.data == null ? 0 : posts2.data!.docs.length,
                itemBuilder: (context, index) {
                  var currPost = posts2?.data!.docs[index].id;
                  if (savedPosts != null && savedPosts!.contains(currPost)) {
                    return post(
                      snapshot: posts2,
                      index: index,
                      screen: 'timeline',
                    );
                  } else {
                    return Container();
                  }
                }),
            onRefresh: () async {
              setState(() {});
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
      profileImage = userData?.pictureUrl;
      savedPosts = userData?.savedPosts;
      rating = userData?.rating;
      savedNum = userData?.saved;
      widget.followingNum = widget.followingNum ?? userData?.following;
      widget.followersNum = widget.followersNum ?? userData?.followers;
      currUid = uid ?? user.getCurrUid();
      username = userData?.name ?? 'Mclovin';
      user.updateSaved();
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

        if(widget.followingNum == null || widget.followingNum == null){
          if(user.isAuthenticated && user.checkAlreadyFollowing(currUid)){
            followButtonText = 'Following';
          }
          widget.followersNum = userData?.followers;
          widget.followingNum = userData?.following;
        }

        return RefreshIndicator(
            child: StreamBuilder(
              stream: PostManager().getUserPosts(uid),
              builder: (context, snapshot2) {
                if (!snapshot2.hasData) {
                  return Scaffold(
                    appBar: AppBar(
                      centerTitle: false,
                      title: Text(username),
                    ),
                    body: const Center(
                        child: CircularProgressIndicator.adaptive()),
                  );
                }
                if (snapshot2.hasError) {
                  Navigator.pop(context);
                  const snackBar =
                      SnackBar(content: Text('Something went wrong'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                posts = snapshot2;
                if (posts.data!.docs.length == 0) {
                  noPosts = true;
                } else {
                  noPosts = false;
                }

                return _buildView();
              },
            ),
            onRefresh: () async {
              setState(() {});
            });
      },
    );
  }
}
