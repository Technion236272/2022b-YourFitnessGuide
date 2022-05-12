
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:yourfitnessguide/utils/globals.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  final List<TextEditingController> _controllerInput = [];
  final List<TextField> _textFieldInput = [];
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
              Text(
                "Workout name",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.name,
                controller: workoutNameController,
                textAlign: TextAlign.left,
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
              Text(
                "Description",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                minLines: 1,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                controller: DescriptionController,
                textAlign: TextAlign.left,
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
              Text(
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
            title: Text('Lose Weight'),
            value: loseWeight,
            //groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  loseWeight = value;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: Text('Gain Muscle'),
            value: gainMuscle,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  gainMuscle = value;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: Text('Gain Healthy Weight'),
            value: gainWeight,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  gainWeight = value;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: Text('Maintain Healthy Lifestyle'),
            value: maintainHealth,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  maintainHealth = value;
                })),
      ],
    );
  }

  Widget _buildExercises(double height, double width) {
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
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
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
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: _textFieldInput.elementAt(index),
                  );
                },
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(3, 8, 40, 10),
                  child: ElevatedButton(
                    child: const Text("Add Exercise"),
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xff84C59E),
                        shadowColor: appTheme,
                        elevation: 1,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        fixedSize: Size(width * 0.3, height * 0.040),
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                      _addInputField(context);
                    },
                  )),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create a workout',
        ),
        backgroundColor: appTheme,
        centerTitle: true,
      ),
      body:
      SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: height * 0.012,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
                child: _buildWorkoutName(height),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
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
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text('ATTACH PHOTO',
                            style: TextStyle(
                              color: appTheme,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('CANCEL',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: appTheme,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('OK',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: appTheme,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ]),
              ),
            ]),
      ),

      resizeToAvoidBottomInset: true,
    );
  }

  _addInputField(context) {
    final inputController = TextEditingController();
    final inputField = _generateInputField(inputController);
    setState(() {
      _controllerInput.add(inputController);
      _textFieldInput.add(inputField);
    });
  }

  _generateInputField(inputController) {
    return TextField(
      controller: inputController,
    );
  }
}
