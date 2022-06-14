import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class search extends StatefulWidget {
  final String searchHint;
  final ValueChanged<String> onChanged;

  const search({required this.searchHint, required this.onChanged, Key? key})
      : super(key: key);

  @override
  State<search> createState() => _searchState();
}

class ViewUsersScreen extends StatefulWidget {
  late var origin;
  late var currID;
  List<String>? imFollowingList = [];
  Map<String, String> buttonsTexts = {};

  ViewUsersScreen({Key? key, required this.origin, required this.currID})
      : super(key: key);

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _searchState extends State<search> {
  final searchUserController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: searchUserController,
        onChanged: (text) {
          setState(() {
            widget.onChanged(text);
          });
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: appTheme),
          suffixIcon: searchUserController.text.isNotEmpty
              ? GestureDetector(
                  child: const Icon(Icons.close, color: appTheme),
                  onTap: () {
                    searchUserController.clear();
                    widget.onChanged('');
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              : null,
          hintText: widget.searchHint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  double height = 10;
  double width = 10;
  List<SearchUserModel> allUsers = [];
  List<SearchUserModel> users = [];
  String query = '';
  var user;
  final searchUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    FirebaseDB().getUsers().then((result) {
      allUsers = List.from(result);
      users = List.from(result);
    });
  }

  Widget buildFollowButton(String uid) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xff84C59E),
            shadowColor: appTheme,
            side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            fixedSize: Size(width * 0.32, height * 0.03),
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            )),
        onPressed: () async {
          if (widget.buttonsTexts[uid] == 'Follow') {
            setState(() {
              widget.buttonsTexts[uid] = 'Following';
              //user.modifyFollow(currUid, true);
            });
          } else {
            setState(() {
              widget.buttonsTexts[uid] = 'Follow';
              //user.modifyFollow(currUid, false);
            });
          }
        },
        child: Text(widget.buttonsTexts[uid]!));
  }

  Widget buildUser(SearchUserModel model) {
    return StatefulBuilder(builder: (context,setState2) {
      return ListTile(
          onTap: () {
            SearchArguments arg = SearchArguments(uid: model.uid!, isUser: false);
            Navigator.pushNamed(context, '/profile', arguments: arg);
          },
          title: Container(
              padding: EdgeInsets.symmetric(vertical: height * 0.01),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: height * 0.06,
                            height: height * 0.06,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 3,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1))
                                ],
                                shape: BoxShape.circle,
                                image: model.pictureUrl == null
                                    ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.asset('images/decorations/mclovin.png').image)
                                    : DecorationImage(fit: BoxFit.cover, image: model.picture.image))),
                        SizedBox(width: width * 0.02),
                        Text(model.name!),
                      ],
                    ),
                    (!user.isAuthenticated || model.uid == user!.uid)
                        ? Container()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: const Color(0xff84C59E),
                                shadowColor: appTheme,
                                side: BorderSide(
                                    width: 2.0, color: Colors.black.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                fixedSize: Size(width * 0.32, height * 0.03),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                )),
                            onPressed: () async {
                              if (widget.buttonsTexts[model.uid] == 'Following') {
                                setState2(() {
                                  widget.buttonsTexts[model.uid!] = 'Follow';
                                  user.modifyFollow(model.uid!, true);
                                });
                              } else {
                                setState2(() {
                                  widget.buttonsTexts[model.uid!] = 'Following';
                                  user.modifyFollow(model.uid!, false);
                                });
                              }
                            },
                            child: Text(widget.buttonsTexts[model.uid]!))
                  ],
                ),
                SizedBox(height: height * 0.02),
              ])));
    },);
  }

  void searchUser(String searchContent) {
    final filteredUsers = allUsers.where((user) {
      final titleLower = user.name!.toLowerCase();
      final searchContentLower = searchContent.toLowerCase();
      return titleLower.contains(searchContentLower);
    }).toList();
    setState(() {
      users = filteredUsers;
      query = searchContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool following = widget.origin == 'following' ? true : false;
    user = Provider.of<AuthRepository>(context);
    var userData;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    List<String>? followList = [];
    return FutureBuilder(
        future: FirebaseDB().getUserModel(widget.currID),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: following ? const Text('Following') : const Text('Followers'),
              ),
              body: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (userSnapshot.hasError) {
            Navigator.pop(context);
            const snackBar = SnackBar(content: Text('Something went wrong'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          userData = userSnapshot.data;
          followList = following ? userData.imFollowing : userData.followingMe;
          widget.imFollowingList = userData.imFollowing;
          return FutureBuilder(
              future: FirebaseDB().getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Scaffold(
                    appBar: AppBar(
                      title: following
                          ? const Text('Following')
                          : const Text('Followers'),
                    ),
                    body: const Center(
                        child: CircularProgressIndicator.adaptive()),
                  );
                }
                if (snapshot.hasError) {
                  Navigator.pop(context);
                  const snackBar =
                      SnackBar(content: Text('Something went wrong'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                allUsers = snapshot.data as List<SearchUserModel>;

                return Scaffold(
                  appBar: AppBar(
                    centerTitle: false,
                    title:
                        following ? const Text('Following') : const Text('Followers'),
                  ),
                  body: Column(
                    children: [
                      search(
                        searchHint: following
                            ? 'Search following'
                            : 'Search followers',
                        onChanged: searchUser,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 0,
                        thickness: 0.75,
                        indent: width * 0.05,
                        endIndent: width * 0.05,
                      ),
                      Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final currUser = users[index];
                              if (!followList!.contains(currUser.uid)) {
                                return Container();
                              }
                              bool? alreadyFollowing = user.checkImAlreadyFollowing(currUser.uid!);
                              widget.buttonsTexts.addAll({currUser.uid!: alreadyFollowing!? 'Following':'Follow'});
                              return buildUser(currUser);
                            },
                      ))
                    ],
                  ),
                );
              });
        });
    ;
  }
}
