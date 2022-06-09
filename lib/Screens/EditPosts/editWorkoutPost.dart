import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/ImageCrop.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class EditWorkout extends StatefulWidget {
  late var post_data;
   EditWorkout({Key? key, this.post_data}) : super(key: key);

  @override
  State<EditWorkout> createState() => _EditWorkoutState();
}

class _EditWorkoutState extends State<EditWorkout> {
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  get post_data => widget.post_data;
  bool? loseWeight ;
  bool? gainMuscle ;
  bool? gainWeight ;
  bool? maintainHealth ;
  bool selectedGoal =false;
  final List<bool?> _goals = [false, false, false, false];
  final List<TextEditingController> _controllerInput = [];
  final List<TextField> _textFieldInput = [];
  final List<String?> _exercises = [];
  var color = appTheme;
  String photo = "Add Image";
  int firsttime=0;

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

      final croppedFile = await myImageCropper(selectedImage.path);

      setState(() {
        _postImageFile = File(croppedFile!.path); //File(selectedImage.path);
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
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: false
                      ? Center(
                    child: Text("Workout name"),
                  )
                      : Text("Workout name"),
                  hintStyle:
                  TextStyle(height: 1, fontSize: 16, color: Colors.grey),
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
                maxLines: 40,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                textAlign: TextAlign.left,
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
            title: const Text('Gain Muscle'),
            value: gainMuscle,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
              gainMuscle = value;
              _goals[1] = value!;
            })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: const Text('Gain Healthy Weight'),
            value: gainWeight,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
              gainWeight = value;
              _goals[2] = value!;
            })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 0.5,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            title: const Text('Maintain Healthy Lifestyle'),
            value: maintainHealth,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
              maintainHealth = value;
              _goals[3] = value!;
            })),
      ],
    );
  }

  Widget _buildExercises(double height, double width) {
    final iconSize = height * 0.050;
    if (_textFieldInput.isEmpty) {
      for (int i = 0; i < post_data.data()!["exercises"]!.length; i++) {
        _addInputField2(context, post_data.data()!["exercises"]![i]);
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
              Container(
                  padding: const EdgeInsets.fromLTRB(3, 8, 40, 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: appTheme,
                        side: BorderSide(
                            width: 2.0, color: Colors.black.withOpacity(0.5)),
                        shadowColor: appTheme,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        fixedSize: Size(width * 0.3, height * 0.040),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                      _addInputField(context);
                    },
                    child: const Text("Add Exercise"),
                  )),
            ],
          ),
        ),
      ],
    );
  }
  Future _fileFromImageUrl() async {
    if (post_data.data()!['image_url'] != null) {
      var rng = new Random();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file =
      new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
      http.Response response =
      await http.get(Uri.parse(post_data.data()!['image_url']!));
      await file.writeAsBytes(response.bodyBytes);
      _postImageFile = file;
      color = Colors.red;
      photo = "Remove Image";
      if (!mounted) return;
      setState(() {
        build(context);
      });
    }
  }

  @override
  initState() {
    super.initState();
    workoutNameController.text=post_data.data()!['title']!;
    descriptionController.text=post_data.data()!['description']!;
    if(firsttime==0) {
      _fileFromImageUrl();
      firsttime++;
    }

    _goals[0]=post_data.data()!['goals']![0];
    _goals[1]=post_data.data()!['goals']![1];
    _goals[2]= post_data.data()!['goals']![2];
    _goals[3]=post_data.data()!['goals']![3];
    loseWeight = post_data.data()!['goals']![0] as bool;
    gainMuscle = post_data.data()!['goals']![1] as bool;
    gainWeight = post_data.data()!['goals']![2] as bool;
    maintainHealth = post_data.data()!['goals']![3] as bool;
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    var timestamp=post_data.data()!['createdAt']!;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Edit workout',
          ),
          backgroundColor: appTheme,
          centerTitle: false,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    _isLoading
                        ? const Center(
                        child: CircularProgressIndicator.adaptive())
                        : IconButton(
                        onPressed: () async {
                          for (int i = 0;
                          i < _controllerInput.length;
                          i++) {
                            if (_controllerInput[i].text.toString() != "") {
                              _exercises
                                  .add(_controllerInput[i].text.toString());
                            }
                          }
                          final String title = workoutNameController.text;
                          final String description =
                              descriptionController.text;
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            await _postManager.deletePost(post_data.id);
                            bool isSubmitted =
                            await _postManager.updateWorkout(
                                title: title,
                                description: description,
                                timeStamp: timestamp,
                                postImage: _postImageFile,
                                goals: _goals,
                                exercises: _exercises);
                            setState(() {
                              _isLoading = false;
                            });

                            if (isSubmitted) {
                              const snackBar = SnackBar(
                                  content:
                                  Text('Workout edited successfully'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);

                              Navigator.pop(context);
                            } else {
                              const snackBar = SnackBar(
                                  content: Text(
                                      'There was a problem logging you in'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        },
                        icon: const Icon(Icons.check_sharp,
                            color: Colors.white)),
                  ],
                )),
          ]),
      body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(mainAxisAlignment: MainAxisAlignment.start,
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
                  (_postImageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _postImageFile!,
                      height: 300,
                      width: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.contain,
                    ),
                  )
                      : const Padding(padding: EdgeInsets.all(0))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 40, 10),
                    width: 205,
                    height: 80.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                            width: 2.0, color: Colors.black.withOpacity(0.5)),
                        primary: color, // background
                        onPrimary: Colors.white, // foreground
                      ),
                      onPressed: () async {
                        if (_postImageFile == null) {
                          await pickImage();
                          if (_postImageFile != null) {
                            color = Colors.red;
                            photo = "Remove Image";
                          }
                        } else {
                          _postImageFile = null;
                          color = appTheme;
                          photo = "Add Image";
                        }
                        setState(() {
                          build(context);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.add_photo_alternate,
                              color: Colors.white),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            photo,
                            style: const TextStyle(color: Colors.white),
                          ),
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
  _addInputField2(context, String input) {
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
    );
  }
}
