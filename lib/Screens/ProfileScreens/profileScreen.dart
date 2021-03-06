import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/widgets.dart';
import 'package:yourfitnessguide/utils/post.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  late String? uid;
  int? followingNum = null, followersNum = null, ratingNum = null;

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
  int randomizedCell = -1;
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
  late int initialW, currentW, goalW;
  late Map<String, bool> privacySettings;
  List<String> quotes = [
    'Give it a try.',
    'Go for it.',
    'Why not?',
    'It\'s worth a shot.',
    'What are you waiting for?',
    'What do you have to lose?',
    'You might as well.',
    'Just do it!',
    'There you go!',
    'Keep up the good work.',
    'Keep it up.',
    'Good job.',
    'Hang in there.',
    'Don\'t give up.',
    'Keep pushing.',
    'Keep fighting!',
    'Stay strong.',
    'Never give up.',
    'Never say \'die\'.',
    'Come on! You can do it!.',
    'It\'s your call.',
    'Follow your dreams.',
    'Reach for the stars.',
    'Do the impossible.',
    'Believe in yourself.',
    'The sky is the limit.'
  ];

  get uid => widget.uid;
  int savedNum = 0;

  Widget _buildStatline({required String stat, required int value, String? redirection}) {
    var val =
        (privacySettings.containsKey('profile') && privacySettings['profile']!)
            ? 'N/A'
            : value.toString();
    var statTitle = Text(stat, style: const TextStyle(color: appTheme, fontSize: 12));
    return Center(
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
          redirection == ''
              ? FittedBox(child: TextButton(onPressed: () {}, child: statTitle))
              : FittedBox(
                  child: TextButton(
                      onPressed: () {
                        var args = {'currID': currUid};
                        Navigator.pushNamed(context, redirection!, arguments: args);
                      },
                      child: statTitle)),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String tabText) {
    return Tab(
        child: FittedBox(
            child: Text(tabText,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appTheme,
                    fontSize: 15))));
  }

  Widget _buildTopDisplayRow(double height, double width, int savedNum) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildStatline(
                stat: 'Rating',
                value: userData?.rating ?? 0, //todo try widget.ratingNum ?? 0,
                redirection: ''),
          ),
        ),
        Expanded(
            child: visiting
                ? Container()
                : _buildStatline(
                    stat: 'Saved', value: savedNum, redirection: '')),
        Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: imageContainer(
              height: height,
              width: width,
              imageLink: profileImage,
              percent: 0.15,
            )),
        Expanded(
          child: Container(
            child: _buildStatline(
                stat: 'Following',
                value: widget.followingNum ?? 0,
                redirection: (privacySettings.containsKey('profile') &&
                        (privacySettings['following']! || privacySettings['profile']!))
                    ? ''
                    : '/following'),
          ),
        ),
        Expanded(
          child: Container(
            child: _buildStatline(
                stat: 'Followers',
                value: widget.followersNum ?? 0,
                redirection: (privacySettings.containsKey('profile') &&
                        (privacySettings['followers']! || privacySettings['profile']!))
                    ? ''
                    : '/followers'),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: visiting
          ? [
              _buildTabHeader('All posts'),
              _buildTabHeader('Meals'),
              _buildTabHeader('Workouts'),
            ]
          : [
              _buildTabHeader('All posts'),
              _buildTabHeader('Meals'),
              _buildTabHeader('Workouts'),
              _buildTabHeader('Saved'),
            ],
    );
  }

  Widget emptyNote(double height, double width, String text) {
    text =
        (privacySettings.containsKey('profile') && privacySettings['profile']!)
            ? 'User profile is private'
            : text;
    return RefreshIndicator(
        child: Card(
            color: Colors.grey[200],
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: height * 0.01),
                    Flexible(
                        child: Text(
                          text,
                          style: const TextStyle(fontSize: 20),
                        )
                    ),
                    Flexible(
                        child: Image.asset(
                          'images/decorations/404.png',
                          width: width * 0.3,
                          height: height * 0.3,
                        )
                    )
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
      var pronoun = visiting ? 'User hasn\'t' : 'You have not';
      if (category == 'Meal Plan' && !mealsFound) {
        return emptyNote(
            height, width, '${pronoun} published a $category yet');
      } else if (category == 'Workout' && !workoutsFound) {
        return emptyNote(
            height, width, '${pronoun} published a $category yet');
      }
    }

    var tmp = ListView.builder(
      //separatorBuilder: (context, index) => const Divider(),
      itemCount: posts.data == null ? 0 : posts.data!.docs.length,
      itemBuilder: (context, index) {
        if (posts.connectionState == ConnectionState.waiting && posts.data == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (posts.connectionState == ConnectionState.done && posts.data == null) {
          return const Center(child: Text('No data available'));
        }
        if (category != null && posts?.data!.docs[index].data()!['category'] != category) {
          return Container();
        }
        return Post(
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

  double calculatePercent() {
    try {
      var tmp = goalW - initialW;
      var tmp2 = currentW - initialW;
      double percent = 0;
      if (tmp != 0) {
        percent = tmp2 / tmp;
      } else {
        percent = 0.5;
      }

      var res = percent >= 0 ? percent : (-1) * percent;
      return (percent <= 0 || percent >= 2) ? 0 : res;
    } catch (_) {
      return 0;
    }
  }

  String randomizeProgressMessage() {
    var random = Random();
    if (randomizedCell == -1) {
      randomizedCell = random.nextInt(quotes.length);
    }
    return quotes[randomizedCell];
  }

  Widget buildProgressbar() {
    return Padding(
      padding: EdgeInsets.only(
          right: width * 0.01,
          left: width * 0.03,
          top: height * 0.005,
          bottom: height * 0.005),
      child: LinearPercentIndicator(
        width: MediaQuery.of(context).size.width - 170,
        animation: true,
        lineHeight: 20.0,
        animationDuration: 2000,
        percent: calculatePercent(),
        leading: const Text('Initial Weight', style: TextStyle(fontSize: 12.0)),
        trailing: const Text('Goal Weight', style: TextStyle(fontSize: 12.0)),
        center: Text(randomizeProgressMessage(),
            style: const TextStyle(fontSize: 12.0)),
        progressColor: appTheme,
        barRadius: const Radius.circular(40.0),
      ),
    );
  }

  Widget _buildView() {
    if (userData != null) {
      profileImage = userData?.pictureUrl;
      username = userData?.name ?? 'Undefined name';
    }
    return Scaffold(
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
                              icon:
                                  const Icon(Icons.edit, color: Colors.white)),
                          IconButton(
                              onPressed: () {
                                user.signOut();
                                setState(() {});
                              },
                              icon:
                                  const Icon(Icons.logout, color: Colors.white))
                        ],
                      )),
                ],
        ),
        body: DefaultTabController(
            length: visiting ? 3 : 4,
            child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                            padding: EdgeInsets.only(top: height * 0.035),
                            child:
                                _buildTopDisplayRow(height, width, savedNum)),
                        (!visiting || !user.isAuthenticated)
                            ? Container()
                            : Container(
                                padding: EdgeInsets.symmetric(horizontal: width * 0.34),
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: followButtonText == 'Following'? Colors.white : const Color(0xff84C59E),
                                        side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                        fixedSize: Size(width * 0.32, height * 0.03),
                                        textStyle: const TextStyle(fontSize: 20, color: Colors.white)
                                    ),
                                    onPressed: () async {
                                      if (followButtonText == 'Following') {
                                        setState(() {
                                          followButtonText = 'Follow';
                                          if (widget.followersNum != null) {
                                            widget.followersNum = widget.followersNum! - 1;
                                          }
                                          user.modifyFollow(currUid, true);
                                        });
                                      } else {
                                        setState(() {
                                          followButtonText = 'Following';
                                          if (widget.followersNum != null) {
                                            widget.followersNum = widget.followersNum! + 1;
                                          }
                                          user.modifyFollow(currUid, false);
                                        });
                                      }
                                    },
                                    child: Text(followButtonText, style: TextStyle(color: followButtonText == 'Following'? Colors.green : Colors.white)))),
                        visiting ? Container() : buildProgressbar(),
                      ]),
                    )
                  ];
                },
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabBar(),
                    SizedBox(height: height * 0.005),
                    Flexible(
                      child: TabBarView(
                        children: !visiting
                            ? (noPosts
                                ? [
                                    emptyNote(height, width, 'You have not published a post yet'),
                                    emptyNote(height, width, 'You have not published a Meal Plan yet'),
                                    emptyNote(height, width, 'You have not published a Workout yet'),
                                    savedNum == 0
                                        ? emptyNote(height, width,'You have not saved a post yet')
                                        : (_buildSaved()),
                                  ]
                                : [
                                    _buildTab(),
                                    _buildTab(category: "Meal Plan"),
                                    _buildTab(category: "Workout"),
                                    savedNum == 0
                                        ? emptyNote(height, width, 'You have not saved a post yet')
                                        : (_buildSaved()),
                                  ])
                            : (noPosts
                                ? [
                                    emptyNote(height, width, 'User has not published a post yet'),
                                    emptyNote(height, width, 'User has not published a Meal Plan yet'),
                                    emptyNote(height, width, 'User has not published a Workout yet'),
                                  ]
                                : [
                                    _buildTab(),
                                    _buildTab(category: "Meal Plan"),
                                    _buildTab(category: "Workout"),
                                  ]),
                      ),
                    ),
                  ],
                ))));
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>?>> _buildSaved({String? category}) {
    return StreamBuilder(
      stream: PostManager().getAllPosts('createdAt'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(centerTitle: false, title: Text(username)),
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
                    return Post(
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
      if (user.isAuthenticated && user.uid == uid) {
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

    try {
      if (userData != null && user.isAuthenticated) {
        user.updateSaved();
        user.updateFollow();
        if (!visiting) {
          userData = user.userData;
        }
        profileImage = userData?.pictureUrl;
        savedPosts = userData?.savedPosts;
        savedNum = userData?.saved;
        currentW = userData?.cWeight;
        goalW = userData?.gWeight;
        initialW = userData?.iWeight;
        widget.followingNum = widget.followingNum ?? userData?.following;
        widget.followersNum = widget.followersNum ?? userData?.followers;
        widget.ratingNum = userData?.rating;
        currUid = uid ?? user.uid;
        username = userData?.name ?? '';
        privacySettings = !visiting
            ? {'profile': false, 'following': false, 'followers': false}
            : userData?.privacySettings;
      }
    } catch (_) {}

    return FutureBuilder(
      future: FirebaseDB().getUserModel(currUid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(centerTitle: true),
            body: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (snapshot.hasError) {
          Navigator.pop(context);
          const snackBar = SnackBar(content: Text('Something went wrong'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        userData = snapshot.data;
        FirebaseDB().updateFollow(userData, currUid!);

        if (widget.followingNum == null ||
            widget.followingNum == null ||
            widget.ratingNum == null) {
          if (user.isAuthenticated && user.checkImAlreadyFollowing(currUid)) {
            followButtonText = 'Following';
          }
          widget.followersNum = userData?.followers;
          widget.followingNum = userData?.following;
          widget.ratingNum = userData?.rating;
        }
        privacySettings = visiting
            ? userData?.privacySettings
            : {'profile': false, 'following': false, 'followers': false};

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

                if (privacySettings.containsKey('profile') &&
                    privacySettings['profile']!) {
                  noPosts = true;
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
