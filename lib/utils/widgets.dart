import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

class GoalChoices extends StatefulWidget {
  late double height, width;
  Goal? userGoal;

  GoalChoices({Key? key, required this.height, required this.width, required this.userGoal})
      : super(key: key);

  @override
  State<GoalChoices> createState() => _GoalChoicesState();
}

class _GoalChoicesState extends State<GoalChoices> {
  set userGoal(Goal newGoal){
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
                  print(userGoal);

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
                  print(userGoal);


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
                  print(userGoal);
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
                  print(userGoal);

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
  imageContainer({Key? key, required this.height, required this.width, required this.percent, this.imageLink, this.imageFile}) : super(key: key);

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
            image: imageFile!= null? DecorationImage(fit: BoxFit.cover, image: Image.file(imageFile!).image) : (imageLink == null
                ? DecorationImage(
                fit: BoxFit.cover,
                image: Image.asset('images/decorations/mclovin.png').image)
                : DecorationImage(
                fit: BoxFit.cover, image: NetworkImage(imageLink!)))));
  }
}

class textField extends StatefulWidget {
  TextEditingController controller = TextEditingController();
  late String fieldName;
  bool? centeredLabel = false;
  textField({Key? key, required this.fieldName, this.centeredLabel}) : super(key: key);


  @override
  State<textField> createState() => _textFieldState();
}

class _textFieldState extends State<textField> {
  get controller => widget.controller;
  get fieldName => widget.fieldName;
  get centeredLabel => widget.centeredLabel;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 5),
        label: centeredLabel? Center(child: Text(fieldName),) : Text(fieldName),
        labelStyle: TextStyle(
          color: appTheme,
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}