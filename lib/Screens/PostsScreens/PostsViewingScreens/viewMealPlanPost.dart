import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/managers/notifications_manager.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/services.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yourfitnessguide/utils/users.dart';

class ViewMealPlanScreen extends StatefulWidget {
  late var post_data;
  late bool? isDownvoted = null;
  late bool? isUpvoted = null;
  late bool isAuthenticated;
  late bool? isSaved = null;
  late String? rating = null;

  ViewMealPlanScreen({Key? key, this.post_data}) : super(key: key);

  @override
  State<ViewMealPlanScreen> createState() => _ViewMealPlanScreenState();
}

class _ViewMealPlanScreenState extends State<ViewMealPlanScreen> {
  get post_data => widget.post_data;
  TextEditingController mealPlanNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController mealNameController = TextEditingController();
  TextEditingController mealIngredientsController = TextEditingController();
  late String calories;
  late String proteins;
  late String carbs;
  late String fats;
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  bool selectedGoal = false;
  late double height, width;
  final List<String?> _mealNames = [];
  final List<String?> _mealIngredients = [];
  final List<Widget> _list = [];
  final List<int> _mealsContents = [0, 0, 0, 0];
  final PostManager _postManager = PostManager();
  late var user_data;
  var user;

  Widget _buildButton(String Name, double height, double width) {
    int index = _mealNames.indexOf(Name);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    // side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    fixedSize: Size(width * 0.3, height * 0.010),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: appTheme,
                    )),
                onPressed: () {},
                child: Text(Name,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: appTheme)),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(
                            width: 2.0, color: Colors.black.withOpacity(0.5)),
                        primary: const Color(0xff84C59E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0)),
                        fixedSize: Size(width * 0.2, height * 0.010),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: appTheme,
                        )),
                    onPressed: () {
                      index = _mealNames.indexOf(Name);
                      String? mealName = _mealNames.elementAt(index);
                      String? mealIngredient =
                          _mealIngredients.elementAt(index);
                      createMealDialog(context, mealName, mealIngredient);
                    },
                    child: const Text("More"),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: height * 0.01),
      ],
    );
  }

  void _addButtonWidget(String name, double height, double width) {
    setState(() {
      if (name != "") _list.add(_buildButton(name, height, width));
    });
  }

  Widget _buildmealPlanName(double height) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/post_name.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Plan name",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.name,
                controller: mealPlanNameController,
                textAlign: TextAlign.left,
                readOnly: true,
                decoration: const InputDecoration(border: InputBorder.none),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(double height) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/description.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /* Text(
                "Description",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),

              */
              TextField(
                minLines: 1,
                maxLines: 40,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                textAlign: TextAlign.left,
                readOnly: true,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 5),
                    label: false
                        ? Center(
                            child: Text("Description"),
                          )
                        : Text("Description"),
                    hintStyle:
                        TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                    labelStyle: TextStyle(
                      color: appTheme,
                      fontSize: 27,
                      fontWeight: FontWeight.normal,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: InputBorder.none),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoal(double height, double width) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/goal.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Goal",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              _buildGoalChoices(height, width),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String stat, String val) {
    Widget content = Column(
      children: [
        SizedBox(height: height * 0.02),
        Text(
          stat,
          style: const TextStyle(
              color: appTheme, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(val, style: const TextStyle(color: appTheme, fontSize: 19)),
      ],
    );
    return Container(
        height: height * 0.1,
        width: height * 0.1,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: content);
  }

  Widget _buildContents(double height) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/exercises.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          //flex: 8,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Ingredients",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, iconSize, 0),
                child: TextField(
                  minLines: 1,
                  maxLines: 40,
                  keyboardType: TextInputType.multiline,
                  controller: mealIngredientsController,
                  textAlign: TextAlign.left,
                  readOnly: true,
                  decoration: InputDecoration(
                      //prefix: Icon(Icons.ac_unit),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey[100]
                      //fillColor: Colors.red
                      ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalChoices(double height, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
            title: const Text('Lose Weight'),
            value: post_data["goals"][0] as bool,
            //groupValue: userGoal,
            activeColor: appTheme,
            onChanged: null),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: const Text('Gain Muscle'),
            value: post_data["goals"][1] as bool,
            activeColor: appTheme,
            onChanged: null),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: const Text('Gain Healthy Weight'),
            value: post_data["goals"][2] as bool,
            activeColor: appTheme,
            onChanged: null),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: const Text('Maintain Healthy Lifestyle'),
            value: post_data["goals"][3] as bool,
            activeColor: appTheme,
            onChanged: null),
      ],
    );
  }

  Widget _buildMealContents(double height, double width) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildStat('Calories', calories)),
            SizedBox(width: 0.05 * width),
            Expanded(child: _buildStat('Proteins', proteins)),
            SizedBox(width: 0.05 * width),
            Expanded(child: _buildStat('Carbs', carbs)),
            SizedBox(width: 0.05 * width),
            Expanded(child: _buildStat('Fats', fats))
          ],
        ));
  }

  Widget _buildMeals(double height, double width) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/food.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Meals",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    return _list[index];
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<String>?> createMealDialog(
      BuildContext context, String? mealName, String? mealIngredients) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    int index = -1;
    if (mealName == null && mealIngredients == null) {
      mealNameController.clear();
      mealIngredientsController.clear();
    } else {
      mealNameController.text = mealName!;
      mealIngredientsController.text = mealIngredients!;
      index = _mealNames.indexOf(mealName);
    }
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Dialog(
              insetPadding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)),
              elevation: 0,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: height * 0.01),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: _buildContents(
                          height), //Padding(padding: EdgeInsets.all(0))//
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 10),
                      child: Row(
                          //mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(["", ""]);
                              },
                              child: const Text('CANCEL',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: appTheme,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )
                          ]),
                    )
                  ])),
        );
      },
    );
  }

  Widget _buildUpvoteButton() {
    String? postId = post_data!['uid'];
    String? postOwnerId = post_data!['user_uid'];

    List? upvotesList = post_data['upvotes'];
    widget.isUpvoted =
        widget.isUpvoted ?? (upvotesList?.contains(getCurrUid()) ?? false);

    List? downvotesList = post_data['downvotes'];
    widget.isDownvoted =
        widget.isDownvoted ?? (downvotesList?.contains(getCurrUid()) ?? false);

    return IconButton(
        onPressed: () {
          if (widget.isAuthenticated) {
            widget.isUpvoted = !widget.isUpvoted!;
            if (widget.isUpvoted! && widget.isDownvoted!) {
              widget.isDownvoted = false;
              NotificationsManager()
                  .removeNotification(postOwnerId!, postId!, 'downvote');
              user.modifyVote(
                  postId, postOwnerId, 'downvotes', widget.isDownvoted);
            }
            setState(() {});
            user.modifyVote(postId, postOwnerId, 'upvotes', widget.isUpvoted);
            setState(() {});

            /// Notification
            if (widget.isUpvoted!) {
              widget.rating = (int.parse(widget.rating!) + 1).toString();
              NotificationsManager().addNotification(postId!, 'upvote', '');
            } else {
              widget.rating = (int.parse(widget.rating!) - 1).toString();
              NotificationsManager()
                  .removeNotification(postOwnerId!, postId!, 'downvote');
            }
          } else {
            const snackBar =
                SnackBar(content: Text('You need to sign in to upvote posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: Icon(Icons.thumb_up,
            color: widget.isUpvoted! ? appTheme : Colors.white));
  }

  Widget _buildDownvoteButton() {
    String? postId = post_data!['uid'];
    String? postOwnerId = post_data!['user_uid'];

    List? upvotesList = post_data['upvotes'];
    widget.isUpvoted =
        widget.isUpvoted ?? (upvotesList?.contains(getCurrUid()) ?? false);

    List? downvotesList = post_data['downvotes'];
    widget.isDownvoted =
        widget.isDownvoted ?? (downvotesList?.contains(getCurrUid()) ?? false);

    return IconButton(
        onPressed: () {
          if (widget.isAuthenticated) {
            widget.isDownvoted = !widget.isDownvoted!;
            if (widget.isDownvoted! && widget.isUpvoted!) {
              widget.isUpvoted = false;
              user.modifyVote(postId, postOwnerId, 'upvotes', widget.isUpvoted);
              NotificationsManager()
                  .removeNotification(postOwnerId!, postId!, 'upvote');
            }
            setState(() {});
            user.modifyVote(
                postId, postOwnerId, 'downvotes', widget.isDownvoted);

            /// Notification
            if (widget.isDownvoted!) {
              widget.rating = (int.parse(widget.rating!) - 1).toString();
              NotificationsManager().addNotification(postId!, 'downvote', '');
            } else {
              widget.rating = (int.parse(widget.rating!) + 1).toString();
              NotificationsManager()
                  .removeNotification(postOwnerId!, postId!, 'downvote');
            }
          } else {
            const snackBar = SnackBar(
                content: Text('You need to sign in to downvote posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: Icon(Icons.thumb_down,
            color: widget.isDownvoted! ? appTheme : Colors.white));
  }

  Widget _buildSaveButton() {
    return IconButton(
        onPressed: () {
          if (widget.isAuthenticated) {
            widget.isSaved = !widget.isSaved!;
            setState(() {});
            if (!widget.isSaved!) {
              user.modifySaved(post_data['uid'], true);
            } else {
              user.modifySaved(post_data['uid'], false);
            }
          } else {
            const snackBar =
                SnackBar(content: Text('You need to sign in to save posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: Icon(Icons.bookmark,
            color: widget.isSaved! ? appTheme : Colors.white));
  }

  Widget _buildCommentButton() {
    return IconButton(
        onPressed: () {
          String postId = post_data['uid'];
          Navigator.pushNamed(context, commentsRoute, arguments: {
            'postId': postId,
          });
        },
        icon: const Icon(Icons.chat_bubble, color: Colors.white));
  }

// todo to check what happens when we dont add anything
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    height = screenSize.height;
    width = screenSize.width;
    mealPlanNameController.text = post_data["title"];
    descriptionController.text = post_data["description"];
    calories = post_data["meals_contents"][0].toString();
    proteins = post_data["meals_contents"][1].toString();
    carbs = post_data["meals_contents"][2].toString();
    fats = post_data["meals_contents"][3].toString();
    user = Provider.of<AuthRepository>(context);
    widget.isAuthenticated = user.isAuthenticated;
    widget.isSaved = widget.isSaved ?? post_data['isSaved'];
    widget.rating = widget.rating ?? post_data['rating'].toString();
    if (_mealNames.isEmpty) {
      for (int i = 0; i < post_data["meals_name"].length; i++) {
        _mealNames.add(post_data["meals_name"][i] as String);
        _mealIngredients.add(post_data["meals_ingredients"][i] as String);
        _addButtonWidget(post_data["meals_name"][i], height, width);
      }
    }
    user_data = _postManager.getUserInfo(post_data["user_uid"]).asStream();
    // for

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${post_data["title"]}',
        ),
        backgroundColor: appTheme,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          SizedBox(
            height: height * 0.012,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 40, 0),
            child: StreamBuilder<Map<String, dynamic>?>(
                stream: user_data,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting &&
                      userSnapshot.data == null) {
                    return const Center(child: LinearProgressIndicator());
                  }
                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.data == null) {
                    return const ListTile();
                  }
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: GestureDetector(
                        onTap: () {
                          SearchArguments arg = SearchArguments(
                              uid: post_data["user_uid"], isUser: true);
                          Navigator.pushNamed(context, '/profile',
                              arguments: arg);
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(userSnapshot.data!['picture']!),
                        )),
                    title: RichText(
                      text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                              text: post_data['category'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor)),
                          const TextSpan(text: ' by '),
                          TextSpan(text: userSnapshot.data!['name']),
                        ],
                      ),
                    ),
                    subtitle: Text(
                        timeago.format(post_data['createdAt'].toDate(),
                            allowFromNow: true),
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey)),
                  );
                }),
          ),
          Divider(
            height: height * 0.00001,
            thickness: 1,
            color: Colors.black45,
          ),
          (post_data!['image_url'] != null
              ? ClipRRect(
                  //borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    post_data!['image_url']!,
                    //height: 400,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                )
              : const Padding(padding: EdgeInsets.all(0))),
          post_data['image_url'] != null
              ? Divider(
                  height: height * 0.00001,
                  thickness: 1,
                  color: Colors.black45,
                )
              : const Padding(padding: EdgeInsets.all(0)),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 40, 10),
            child: _buildDescription(height),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 40, 20),
            child: _buildGoal(height, width),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
            child: _buildMeals(height, width),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: _buildMealContents(height, width),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0))),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildUpvoteButton(),
                    Text(
                      widget.rating!,
                      style: TextStyle(color: Colors.white),
                    ),
                    _buildDownvoteButton(),
                    _buildCommentButton(),
                    _buildSaveButton(),
                  ],
                )),
          ),
        ]),
      )),
      resizeToAvoidBottomInset: true,
    );
  }
}
