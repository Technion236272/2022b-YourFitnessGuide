import 'dart:io';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
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
                : (DecorationImage(
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
            ? Center(child: Text(widget.fieldName))
            : Text(widget.fieldName),
        hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
        hintText: widget.hint ?? '',
        labelStyle: const TextStyle(color: appTheme, fontSize: 23, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class WideButton extends StatefulWidget {
  late double height, width;
  late Future<void> onPressed;
  late Color? color;

  WideButton(
      {Key? key,
      required this.height,
      required this.width,
      required this.onPressed,
      this.color})
      : super(key: key);

  @override
  State<WideButton> createState() => _WideButtonState();
}

class _WideButtonState extends State<WideButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: widget.color ?? const Color(0xff84C59E),
          shadowColor: appTheme,
          elevation: 17,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          fixedSize: Size(widget.width * 0.9, widget.height * 0.055),
          textStyle: const TextStyle(fontSize: 20, color: Colors.white)),
      onPressed: () {
        widget.onPressed;
      },
      child: const Text("SIGN UP"),
    );
  }
}


Widget emptyNote(String text, double height, double width) {
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
                        style: const TextStyle(fontSize: 20),
                      )),
                  Flexible(
                      child: Image.asset(
                        'images/decorations/binoculars.png',
                        width: width * 0.3,
                        height: height * 0.3,
                      ))
                ],
              )));
}