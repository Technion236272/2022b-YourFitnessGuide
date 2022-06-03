import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/users.dart';

class ViewLeaderboardScreen extends StatefulWidget {
  const ViewLeaderboardScreen({Key? key}) : super(key: key);

  @override
  _ViewLeaderboardScreenState createState() => _ViewLeaderboardScreenState();
}

class _ViewLeaderboardScreenState extends State<ViewLeaderboardScreen> {
  var user;
  List<SearchUserModel> allUsers = [];
  late double height, width;
  int? myRating, myRanking;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    FirebaseDB().getUsers().then((result) {
      allUsers = List.from(result);
    });
  }

  Widget buildUser(SearchUserModel model, int index) => ListTile(
        onTap: () {
          SearchArguments arg = SearchArguments(uid: model.uid!, isUser: false);
          Navigator.pushNamed(context, '/profile', arguments: arg);
        },
        title: Row(
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
                        image: Image.asset(
                            'images/decorations/mclovin.png')
                            .image)
                        : DecorationImage(
                        fit: BoxFit.cover,
                        image: model.picture.image))),
            SizedBox(
              width: 8,
            ),
            Text(model.name!)
          ],
        ),
        leading: Text(
          "#${index + 1}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
            'Rating - ' + model.rating.toString(),
            style: TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildUpperStat() {
    return Container(
      padding: EdgeInsets.only(top: height * 0.03),
      decoration: BoxDecoration(
          color: appTheme,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20))),
      child: Column(
        children: [
          Text(
            'My Ranking',
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: height * 0.006,
          ),
          Divider(
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          SizedBox(
            height: height * 0.006,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    myRating.toString(),
                    style: TextStyle(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text('Rating',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              Column(
                children: [
                  Text('#' + myRanking.toString(),
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      )),
                  Text("Rank",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              )
            ],
          ),
          SizedBox(
            height: height * 0.01,
          )
        ],
      ),
    );
  }

  Widget _buildUpperPlaceholder() {
    return Container(
      padding: EdgeInsets.only(top: height * 0.03),
      decoration: BoxDecoration(
          color: appTheme,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text(
            'Login to see how you rank',
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500),
          )),
          Center(child: Text(
            'against others',
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500),
          )),
          SizedBox(height: height * 0.02,)
        ],
      ),
    );
  }

  Widget _buildView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: Column(
        children: [
          !user.isAuthenticated? _buildUpperPlaceholder():
          _buildUpperStat(),
          SizedBox(height: height * 0.02),
          Expanded(
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildUser(allUsers[index], index);
                },
                separatorBuilder: (context, index) => Divider(
                      thickness: 1,
                      color: Colors.grey,
                      indent: 10,
                      endIndent: 10,
                    ),
                itemCount: allUsers.length),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthRepository>(context);

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return FutureBuilder(
        future: FirebaseDB().getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Leaderboard'),
              ),
              body: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (snapshot.hasError) {
            Navigator.pop(context);
            const snackBar = SnackBar(content: Text('Something went wrong'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          allUsers = snapshot.data as List<SearchUserModel>;
          allUsers.sort((user1, user2) {
            return user2.rating!.compareTo(user1.rating!);
          });
          if(user.isAuthenticated){
            for(int i = 0; i < allUsers.length; i++){
              if(allUsers[i].uid == user.uid){
                myRating = allUsers[i].rating;
                myRanking = i + 1;
                break;
              }
            }
          }
          return _buildView();
        });
  }
}
