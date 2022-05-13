import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
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
            border: Border.all(width: 4, color: const Color(0xffD6D6D6)),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 3,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1))
            ],
            shape: BoxShape.circle,
            image: imageFile != null
                ? DecorationImage(
                    fit: BoxFit.cover, image: Image.file(imageFile!).image)
                : (imageLink == null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            Image.asset('images/decorations/mclovin.png').image)
                    : DecorationImage(
                        fit: BoxFit.cover, image: NetworkImage(imageLink!)))));
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

  post({Key? key, this.index, required this.snapshot}) : super(key: key);

  @override
  State<post> createState() => _postState();
}

class _postState extends State<post> {
  final _postManager = PostManager();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        //TODO: Saleh/ Mohamed: Navigate to viewing post, for Mohamad: Saleh saved post_uid, utilize it
        print('Navigate to post');},
      child:Card(
          elevation: 8,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// user pic + name + 3 dots
                StreamBuilder<Map<String, dynamic>?>(
                    stream: _postManager
                        .getUserInfo(widget.snapshot?.data!.docs[widget.index]
                        .data()!['user_uid'])
                        .asStream(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting &&
                          userSnapshot.data == null) {
                        return const Center(child: LinearProgressIndicator());
                      }
                      if (userSnapshot.connectionState == ConnectionState.done &&
                          userSnapshot.data == null) {
                        return const ListTile();
                      }
                      return ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                          NetworkImage(userSnapshot.data!['picture']!),
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.snapshot?.data!.docs[widget.index]
                                      .data()!['category'],
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
                            timeago.format( widget.snapshot?.data!.docs[widget.index].data()!['createdAt'] != null ?widget.snapshot?.data!.docs[widget.index].data()!['createdAt']
                                .toDate(): DateTime.now(),
                                allowFromNow: true),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey)),
                        trailing: IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.more_horiz,
                              color: Theme.of(context).iconTheme.color,
                            )),
                      );
                    }),
                Text(
                  widget.snapshot?.data!.docs[widget.index].data()!['title']!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.snapshot?.data!.docs[widget.index]
                      .data()!['description']!,
                  textAlign: TextAlign.left,
                ),
                (widget.snapshot?.data!.docs[widget.index].data()!['image_url'] !=
                    null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.snapshot?.data!.docs[widget.index]
                        .data()!['image_url']!,
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Padding(padding: EdgeInsets.all(0))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              const _snackBar =
                              SnackBar(content: Text('Not implemented yet'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(_snackBar);
                            },
                            icon: const Icon(Icons.arrow_upward,
                                color: Colors.grey)),
                        IconButton(
                            onPressed: () {
                              const _snackBar =
                              SnackBar(content: Text('Not implemented yet'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(_snackBar);
                            },
                            icon: const Icon(Icons.arrow_downward,
                                color: Colors.grey))
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          const _snackBar =
                          SnackBar(content: Text('Not implemented yet'));
                          ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                        },
                        icon: const Icon(Icons.chat_bubble, color: Colors.grey)),
                    IconButton(
                        onPressed: () {
                          const _snackBar =
                          SnackBar(content: Text('Not implemented yet'));
                          ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                        },
                        icon: const Icon(Icons.bookmark, color: Colors.grey))
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
