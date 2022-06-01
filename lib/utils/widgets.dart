import 'dart:io';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'globals.dart';

class GoalChoices extends StatefulWidget {
  late double height, width;
  Goal? userGoal;

  GoalChoices(
      {Key? key,
      required this.height,
      required this.width,
      required this.userGoal})
      : super(key: key);

  @override
  State<GoalChoices> createState() => _GoalChoicesState();
}

class _GoalChoicesState extends State<GoalChoices> {
  set userGoal(Goal newGoal) {
    widget.userGoal = newGoal;
  }

  Goal get userGoal => widget.userGoal!;

  get width => widget.width;

  get height => widget.height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<Goal>(
            title: const Text('Lose Weight'),
            value: Goal.loseWeight,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value!;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        RadioListTile<Goal>(
            title: const Text('Gain Muscle'),
            value: Goal.gainMuscle,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value!;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        RadioListTile<Goal>(
            title: const Text('Gain Healthy Weight'),
            value: Goal.gainWeight,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value!;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        RadioListTile<Goal>(
            title: const Text('Maintain Healthy Lifestyle'),
            value: Goal.maintainHealth,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value!;
                })),
      ],
    );
  }
}

class imageContainer extends StatelessWidget {
  late double height;
  late double width;
  late String? imageLink;
  late File? imageFile;
  late double percent;

  imageContainer(
      {Key? key,
      required this.height,
      required this.width,
      required this.percent,
      this.imageLink,
      this.imageFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: height * percent,
        height: height * percent,
        decoration: BoxDecoration(
            border: Border.all(width: 4, color: Colors.grey[500]!),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 3,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1))
            ],
            shape: BoxShape.circle,
            image: imageFile != null
                ? DecorationImage(
                    fit: BoxFit.contain, image: Image.file(imageFile!).image)
                : (imageLink == null
                    ? DecorationImage(
                        fit: BoxFit.contain,
                        image:
                            Image.asset('images/decorations/mclovin.png').image)
                    : DecorationImage(
                        fit: BoxFit.contain,
                        image: NetworkImage(imageLink!)))));
  }
}

class textField extends StatefulWidget {
  TextEditingController controller = TextEditingController();
  late String fieldName;
  bool centered;

  late String? hint;

  textField(
      {Key? key, required this.fieldName, this.centered = false, this.hint})
      : super(key: key);

  @override
  State<textField> createState() => _textFieldState();
}

class _textFieldState extends State<textField> {
  get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      textAlign: widget.centered ? TextAlign.center : TextAlign.left,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 5),
        label: widget.centered
            ? Center(
                child: Text(widget.fieldName),
              )
            : Text(widget.fieldName),
        hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
        hintText: widget.hint ?? '',
        labelStyle: const TextStyle(
          color: appTheme,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class post extends StatefulWidget {
  AsyncSnapshot? snapshot;
  late int? index;
  bool completed = true;
  bool owner = false;
  late Image? userPicture = null;
  late Image? postImage;
  late String? category = null;
  late String? username = null;
  late DateTime? date = null;
  late int? rating = null;
  late String? title = null;
  late String? screen = null;
  late String? uid = null;
  late Map<String,dynamic>? data = null;
  bool hide = true;
  var user;
  bool isSaved = false;
  bool? goalFiltered = false;

  post(
      {Key? key,
      this.index,
      this.snapshot,
      required this.screen,
      this.goalFiltered, this.uid, this.data})
      : super(key: key) {
    StreamBuilder<Map<String, dynamic>?>(
        stream: PostManager()
            .getUserInfo(data?['user_uid'] ?? snapshot?.data!.docs[index].data()!['user_uid'])
            .asStream(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting &&
              userSnapshot.data == null) {
            return const Center(child: LinearProgressIndicator());
          }
          if (userSnapshot.connectionState == ConnectionState.done &&
              userSnapshot.data == null) {
            completed = false;
            return const ListTile();
          }
          userPicture = Image.network(data?['picture'] ?? userSnapshot.data!['picture']!);
          category = data?['category'] ?? snapshot?.data!.docs[index].data()!['category'];
          username = data?['name'] ?? userSnapshot.data!['name'];
          title = data?['title'] ?? userSnapshot.data!['title']!;
          rating = data?['rating'] ?? userSnapshot.data!['rating'];
          date = data != null? (data?['createdAt'].toDate()
              ) : (snapshot?.data!.docs[index].data()!['createdAt'] != null
              ? snapshot?.data!.docs[index].data()!['createdAt'].toDate()
              : DateTime.now());

          return const ListTile();
        });
  }

  @override
  State<post> createState() => _postState();
}

class _postState extends State<post> {
  final _postManager = PostManager();

  Widget _buildPostIcon(IconData ic) {
    return IconButton(
        onPressed: () {
          const snackBar = SnackBar(content: Text('Not implemented yet'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        icon: Icon(ic, color: Colors.grey));
  }

  Widget _buildSaveButton(){
    return IconButton(
          onPressed: () {
            if (widget.user.isAuthenticated) {
              widget.isSaved = !widget.isSaved;
              setState(() {});
              if (!widget.isSaved) {
                const _snackBar = SnackBar(
                    content: Text('Deleting post from saved'));
                ScaffoldMessenger.of(context)
                    .showSnackBar(_snackBar);
                widget.user.modifySaved( widget.data != null? widget.data!['uid']:
                    widget.snapshot?.data!.docs[widget.index].id,
                    true);
              } else {
                const _snackBar =
                SnackBar(content: Text('Saving post'));
                ScaffoldMessenger.of(context)
                    .showSnackBar(_snackBar);
                widget.user.modifySaved( widget.data != null?
                  widget.data!['uid']:
                    widget.snapshot?.data!.docs[widget.index].id,
                    false);
              }
            }
           else {
            const snackBar =
                SnackBar(content: Text('You need to sign in to save posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon:  Icon(Icons.bookmark,
            color: widget.isSaved ? appTheme : Colors.grey));
  }
  @override
  Widget build(BuildContext context) {
    widget.user = Provider.of<AuthRepository>(context);
    if (widget.user.isAuthenticated) {
      var saved = widget.user.savedPosts;
      widget.isSaved = saved == null
          ? false
          : saved.contains(widget.data != null? widget.data!['uid']: widget.snapshot?.data!.docs[widget.index].id);
      var cat = widget.data != null? widget.data!['category']: widget.snapshot?.data!.docs[widget.index].data()!['category'];
      if (widget.goalFiltered != null &&
          widget.goalFiltered! &&
          cat == 'Blog') {
        return Container();
      }

      if (widget.goalFiltered != null && widget.goalFiltered!) {
        var postGoals = widget.data != null? widget.data!['goals']:
            widget.snapshot?.data!.docs[widget.index].data()!['goals'];
        if (cat == "Blog") {
          Container();
        }

          var userGoal = widget.user.userData.goal;
          if (!postGoals[userGoal]!) {
            return Container();
          }

      }
    }

    var tmp = (widget.data?['description'] ?? widget.snapshot?.data!.docs[widget.index].data()!['description'])
        as String;

    return InkWell(
      onTap: () {
        var cat = widget.data?['category'] ?? widget.snapshot?.data!.docs[widget.index].data()!['category'];
        if (cat == 'Blog') {
          Navigator.pushNamed(context, viewBlogRoute,
              arguments: widget.data != null? widget.data : widget.snapshot?.data!.docs[widget.index].data()!);
        } else if (cat == 'Workout') {
          Navigator.pushNamed(context, viewWorkoutRoute,
              arguments: widget.data != null? widget.data : widget.snapshot?.data!.docs[widget.index].data()!);
        } else {
          Navigator.pushNamed(context, viewMealPlanRoute,
              arguments: widget.data != null? widget.data :widget.snapshot?.data!.docs[widget.index].data()!);
        }
      },
      child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// user pic + name + 3 dots
                StreamBuilder<Map<String, dynamic>?>(
                    stream: _postManager
                        .getUserInfo(widget.data?['user_uid'] ?? widget.snapshot?.data!.docs[widget.index]
                            .data()!['user_uid'])
                        .asStream(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          userSnapshot.data == null) {
                        return const Center(child: LinearProgressIndicator());
                      }
                      if (userSnapshot.connectionState ==
                              ConnectionState.done &&
                          userSnapshot.data == null) {
                        return const ListTile();
                      }
                      return ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: widget.userPicture != null
                              ? widget.userPicture?.image
                              : (widget.data?['picture'] ?? NetworkImage(userSnapshot.data!['picture']!)),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.category != null
                                      ? widget.category
                                      : (widget.data?['category'] ?? widget
                                          .snapshot?.data!.docs[widget.index]
                                          .data()!['category']),

                                  style: TextStyle(
                                      //fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor)),
                              const TextSpan(text: ' by '),
                              TextSpan(text: widget.data?['name'] ?? userSnapshot.data!['name']),
                            ],
                          ),
                        ),
                        subtitle: Text(
                            widget.date != null
                                ? timeago.format(widget.date!,
                                    allowFromNow: true)
                                : timeago.format(
                                widget.data != null? (widget.data?['createdAt'].toDate()) : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'] != null
                                    ? widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate()
                                    : DateTime.now()),
                                    allowFromNow: true),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey)),
                        trailing: widget.screen == 'timeline'
                            ? null
                            : PopupMenuButton(
                                icon: const Icon(Icons.more_horiz),
                                /*onSelected: (value) {
                                  PostManager().deletePost(widget
                                      .snapshot?.data!.docs[widget.index].id);
                                },*/
                                onSelected: (value) async {
                                  Widget cancel = TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: appTheme),
                                      ));
                                  Widget confirm = TextButton(
                                      onPressed: () {
                                        widget.user.modifySaved(
                                            widget.snapshot?.data!
                                                .docs[widget.index].id,
                                            true);
                                        PostManager().deletePost(widget.snapshot
                                            ?.data!.docs[widget.index].id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Confirm',
                                          style: TextStyle(color: appTheme)));
                                  AlertDialog alert = AlertDialog(
                                    title: const Text('Are you sure?'),
                                    content: const Text(
                                        'Posts are not retrievable after deletion.'),
                                    actions: [cancel, confirm],
                                  );
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return alert;
                                      });
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                      value: 1, child: Text('Delete post'))
                                ],
                              ),
                      );
                    }),
                Text( widget.data?['title'] ??
                    widget.snapshot?.data!.docs[widget.index].data()!['title']!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text( widget.data != null? widget.data!['description'].substring(0, min(65, tmp.length)) +
                    (65 < tmp.length ? '...' : ''):
                    widget.snapshot?.data!.docs[widget.index]
                            .data()!['description']!
                            .substring(0, min(65, tmp.length)) +
                        (65 < tmp.length ? '...' : ''),
                    textAlign: TextAlign.left,
                    maxLines: 5),
                const SizedBox(height: 5),
    ((widget.data!= null && widget.data!['image_url'] != null) || widget.snapshot?.data!.docs[widget.index]
        .data()!['image_url'] !=
    null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network( widget.data != null? widget.data!['image_url']  : (widget.data?['image_url'] ??
                            widget.snapshot?.data!.docs[widget.index]
                              .data()!['image_url']!),
                          //height: 200,

                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(

                      children: [
                        _buildPostIcon(Icons.arrow_upward),
                        Text(
                          (widget.data?['rating'] ?? widget.snapshot?.data.docs[widget.index]
                                  .data()['rating'])!
                              .toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.9),
                              fontWeight: FontWeight.bold),
                        ),
                        _buildPostIcon(Icons.arrow_downward),
                      ],
                    ),
                    _buildPostIcon(Icons.chat_bubble),
                    _buildSaveButton(),
                  ],
                )

              ],
            ),
          )),
    );
  }
}

class wideButton extends StatefulWidget {
  late double height, width;
  late Future<void> onPressed;
  late Color? color;

  wideButton(
      {Key? key,
      required this.height,
      required this.width,
      required this.onPressed,
      this.color})
      : super(key: key);

  @override
  State<wideButton> createState() => _wideButtonState();
}

class _wideButtonState extends State<wideButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text("SIGN UP"),
      style: ElevatedButton.styleFrom(
          primary: widget.color ?? const Color(0xff84C59E),
          shadowColor: appTheme,
          elevation: 17,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          fixedSize: Size(widget.width * 0.9, widget.height * 0.055),
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          )),
      onPressed: () {
        widget.onPressed;
      },
    );
  }
}

/*
return ElevatedButton(
      child: const Text("SIGN IN"),
      style: ElevatedButton.styleFrom(
          primary: const Color(0xff84C59E),
          shadowColor: appTheme,
          elevation: 17,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          fixedSize: Size(width * 0.9, height * 0.055),
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          )),
      onPressed: () async {
        _validateLogin();
      },
    );


    ElevatedButton(
                      child: const Text("SIGN UP"),
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xff84C59E),
                          shadowColor: appTheme,
                          elevation: 17,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fixedSize: Size(width * 0.9, height * 0.055),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        _validateSignUp();
                      },
                    ),






 */
