import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/managers/notifications_manager.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/services.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yourfitnessguide/utils/users.dart';

class ViewWorkoutScreen extends StatefulWidget {
  late var post_data;
  late bool? isDownvoted = null;
  late bool? isUpvoted = null;
  late bool isAuthenticated;
  late bool? isSaved = null;
  late String? rating = null;

  ViewWorkoutScreen({Key? key, this.post_data}) : super(key: key);

  @override
  State<ViewWorkoutScreen> createState() => _ViewWorkoutScreenState();
}

class _ViewWorkoutScreenState extends State<ViewWorkoutScreen> {
  get post_data => widget.post_data;
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  bool selectedGoal = false;
  final List<TextEditingController> _controllerInput = [];
  final List<TextField> _textFieldInput = [];
  final PostManager _postManager = PostManager();
  late var user_data;
  var user;

  Widget _buildWorkoutName(double height) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/workout.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Workout name",
                  style: TextStyle(color: appTheme, fontSize: 20)),
              TextField(
                keyboardType: TextInputType.name,
                controller: workoutNameController,
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

  Widget _buildExercises(double height, double width) {
    final iconSize = height * 0.050;
    if (_textFieldInput.isEmpty) {
      for (int i = 0; i < post_data["exercises"].length; i++) {
        _addInputField(context, post_data["exercises"][i]);
      }
    }
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
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Exercises",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _controllerInput.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _textFieldInput.elementAt(index),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
              widget.rating = (int.parse(widget.rating!) + 1).toString();
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
              widget.rating = (int.parse(widget.rating!) - 1).toString();
              widget.isUpvoted = false;
              user.modifyVote(postId, postOwnerId, 'upvotes', widget.isUpvoted);
              NotificationsManager().removeNotification(postOwnerId!, postId!, 'upvote');
            }
            setState(() {});
            user.modifyVote(postId, postOwnerId, 'downvotes', widget.isDownvoted);

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    workoutNameController.text = post_data["title"];
    descriptionController.text = post_data["description"];
    user_data = _postManager.getUserInfo(post_data["user_uid"]).asStream();
    user = Provider.of<AuthRepository>(context);
    widget.isAuthenticated = user.isAuthenticated;
    widget.isSaved = widget.isSaved ?? post_data['isSaved'];
    widget.rating = widget.rating ?? post_data['rating'].toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${post_data["title"]}',
        ),
        backgroundColor: appTheme,
        centerTitle: false,
      ),
      bottomSheet: Container(
          alignment: Alignment(0.0, -1.0),
          height: 50,
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
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
          /*
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
                child: _buildWorkoutName(height),
              ),

               */
          Container(
            padding: const EdgeInsets.fromLTRB(8, 1, 0, 0),
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
          //SizedBox(height: height * 0.04),
          post_data!['image_url'] != null
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
            padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
            child: _buildGoal(height, width),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
            child: _buildExercises(height, width),
          ),
          SizedBox(height: height * 0.1),
        ]),
      )),
      resizeToAvoidBottomInset: true,
    );
  }

  // adding string
  _addInputField(context, String input) {
    final inputController = TextEditingController();
    inputController.text = input;
    final inputField = _generateInputField(inputController);
    //inputController.text=
    setState(() {
      _controllerInput.add(inputController);
      _textFieldInput.add(inputField);
    });
  }

  _generateInputField(inputController) {
    return TextField(
      controller: inputController,
      readOnly: true,
      // decoration: InputDecoration(border: InputBorder.none),
    );
  }
}
