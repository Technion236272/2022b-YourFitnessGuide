import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  bool selectedGoal = false;
  List<bool?> _goals = [false, false, false, false];
  final List<TextEditingController> _controllerInput = [];
  final List<TextField> _textFieldInput = [];
  final List<String?> _exercises = [];
  var color = appTheme;
  String photo = "attach a photo";

  final PostManager _postManager = PostManager();
  bool _isLoading = false;
  File? _postImageFile;

  Future pickImage() async {
    try {
      final selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage == null) {
        const snackBar = SnackBar(content: Text('No image was selected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _postImageFile = null;
        return;
      }
      setState(() {
        _postImageFile = File(selectedImage.path);
      });
    } on PlatformException catch (_) {
      const snackBar = SnackBar(
          content: Text(
              'You need to grant permission if you want to select a photo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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
             /* Text(
                "Workout name",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              */
              TextField(
                keyboardType: TextInputType.name,
                controller: workoutNameController,
                textAlign: TextAlign.left,
                maxLength: 30,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  label: false
                      ? Center(
                    child: Text("Workout name"),
                  )
                      : Text("Workout name"),
                  hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 27,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
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
              /*Text(
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
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  label: false
                      ? Center(
                    child: Text("Description"),
                  )
                      : Text("Description"),
                  hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 27,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),

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
                  _goals[0] = value!;
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
                  _goals[1] = value;
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
                  _goals[2] = value;
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
                  _goals[3] = value;
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
                        primary: appTheme,
                        side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
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
          centerTitle: false,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator.adaptive())
                        :
                    IconButton(
                        onPressed: () async {
                          for (int i = 0; i < _controllerInput.length; i++) {
                            if (_controllerInput[i].text.toString() != "") {
                              _exercises.add(_controllerInput[i].text.toString());
                            }
                          }
                          final String title = workoutNameController.text;
                          final String description = descriptionController.text;
                          if (loseWeight! ||
                              gainMuscle! ||
                              gainWeight! ||
                              maintainHealth!) {
                            selectedGoal = true;
                          }
                          if (title == "" ||
                              description == "" ||
                              selectedGoal == false ||
                              _exercises.isEmpty) {
                            const snackBar = SnackBar(
                                content: Text(
                                    'You must fill all the fields and add exercises'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            bool isSubmitted = await _postManager.submitWorkout(
                                title: title,
                                description: description,
                                postImage: _postImageFile,
                                goals: _goals,
                                exercises: _exercises);
                            setState(() {
                              _isLoading = false;
                            });

                            if (isSubmitted) {
                              const snackBar = SnackBar(
                                  content: Text('Workout posted successfully'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);

                              Navigator.pop(context);
                            } else {
                              const snackBar = SnackBar(
                                  content:
                                  Text('There was a problem logging you in'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        },
                        icon:
                            const Icon(Icons.check_sharp, color: Colors.white)),
                  ],
                )),
          ]),
      body: SingleChildScrollView(
          child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
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

              (_postImageFile!=
                  null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _postImageFile!,
                  height: 300,
                  width:
                  MediaQuery.of(context).size.width*0.9,
                  fit: BoxFit.contain,
                ),
              )  : const Padding(
                  padding: EdgeInsets.all(0))),
              SizedBox(
                height: 4,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 40, 10),
                width: 205,
                height: 80.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                    primary: color, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  onPressed: () async {
                    if (_postImageFile == null) {
                      await pickImage();
                      if(_postImageFile!=null) {
                        color = Colors.red;
                        photo = "detach the photo";
                      }
                    }
                    else {
                      _postImageFile = null;
                      color = appTheme;
                      photo = "attach a photo";
                    }
                    setState(() {
                      build(context);
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add_photo_alternate, color: Colors.white),
                      SizedBox(
                        height: 4,
                      ),
                      Text(photo, style: TextStyle(color: Colors.white),),









                    ],
                  ),
                ),
              ),
            ]),
      )),
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
