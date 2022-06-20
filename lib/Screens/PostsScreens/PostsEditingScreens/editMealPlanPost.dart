import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'dart:io';
import 'package:yourfitnessguide/services/image_crop.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:numberpicker/numberpicker.dart';


class EditMealPlan extends StatefulWidget {
  late var post_data;
   EditMealPlan({Key? key, this.post_data}) : super(key: key);

  @override
  State<EditMealPlan> createState() => _EditMealPlanState();
}

class _EditMealPlanState extends State<EditMealPlan> {
  TextEditingController mealPlanNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController mealNameController = TextEditingController();
  TextEditingController mealIngredientsController = TextEditingController();

  Map<String, int> nutrients = {
    'calories': 0,
    'proteins': 0,
    'carbs': 0,
    'fats': 0
  };

  get post_data => widget.post_data;
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  final List<bool?> _goals = [false, false, false, false];
  bool selectedGoal = false;
  final List<String?> _mealNames = [];
  final List<String?> _mealIngredients = [];
  final List<Widget> _list = [];
  final List<int?> _mealsContents = [0, 0, 0, 0];
  var color = appTheme;
  String photo = "Add Image";
  final PostManager _postManager = PostManager();
  bool _isLoading = false;
  File? _postImageFile;
  int firsttime=0;
  bool _alreadyfilled=false;

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
      const snackBar = SnackBar(content: Text('You need to grant permission if you want to select a photo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    fixedSize: Size(width * 0.25, height * 0.010),
                    textStyle: const TextStyle(
                      fontSize: 14,
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
                        primary: const Color(0xff84C59E),
                        side: BorderSide(
                            width: 2.0, color: Colors.black.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0)),
                        fixedSize: Size(width * 0.17, height * 0.010),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  side: BorderSide(
                      width: 2.0, color: Colors.black.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)),
                  fixedSize: Size(width * 0.05, height * 0.010),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: appTheme,
                  )),
              onPressed: () {
                setState(() {
                  index = _mealNames.indexOf(Name);
                  if (index != -1) {
                    _deleteButtonWidget(index);
                  }
                });
              },
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
                size: 24.0,
              ),
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

  void _updateButtonWidget(
      String name, String Ingredients, double height, double width, int index) {
    setState(() {
      if (name != "") {
        _mealNames[index] = name;
        _mealIngredients[index] = Ingredients;
        _list[index] = _buildButton(name, height, width);
      } else {
        _deleteButtonWidget(index);
      }
    });
  }

  void _deleteButtonWidget(int index) {
    setState(() {
      _mealNames.removeAt(index);
      _mealIngredients.removeAt(index);
      _list.removeAt(index);
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
              /* Text(
                "Plan name",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),

              */
              TextField(
                keyboardType: TextInputType.name,
                controller: mealPlanNameController,
                textAlign: TextAlign.left,
                maxLength: 30,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: false
                      ? Center(
                    child: Text("Plan name"),
                  )
                      : Text("Plan name"),
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

  Widget _buildMealName(double height) {
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
          child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, iconSize, 0),
              child: TextField(
                controller: mealNameController,
                textAlign: TextAlign.left,
                maxLength: 30,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: Text("Meal Title"),
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              )),
        ),
      ],
    );
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
            flex: 8,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, iconSize, 0),
              child: TextField(
                minLines: 1,
                maxLines: 40,
                keyboardType: TextInputType.multiline,
                controller: mealIngredientsController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: Text("Ingredients"),
                  hintStyle:
                  TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            )),
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
              _goals[0] = value;
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
            title: const Text('Gain Healthy Weight'),
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
            title: const Text('Maintain Healthy Lifestyle'),
            value: maintainHealth,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
              maintainHealth = value;
              _goals[3] = value;
            })),
      ],
    );
  }

  Widget _buildMealContents(double height, double width) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(children: [
                  const FittedBox(child: Text('Calories', style: TextStyle(color: appTheme, fontSize: 20))),
                  NumberPicker(
                    value: nutrients['calories']!,
                    minValue: 0,
                    maxValue: 5000,
                    itemHeight: 30,
                    step: 10,
                    selectedTextStyle: const TextStyle(color: appTheme, fontSize: 22),
                    onChanged: (value) => setState(() =>  nutrients['calories'] = value),
                  )
                ])
            ),
            SizedBox(width: 0.05 * width),
            Expanded(
                child: Column(children: [
                  const FittedBox(child: Text('Proteins', style: TextStyle(color: appTheme, fontSize: 20))),
                  NumberPicker(
                    value: nutrients['proteins']!,
                    minValue: 0,
                    maxValue: 500,
                    itemHeight: 30,
                    selectedTextStyle: const TextStyle(color: appTheme, fontSize: 22),
                    onChanged: (value) => setState(() =>  nutrients['proteins'] = value),
                  )
                ])
            ),
            SizedBox(width: 0.05 * width),
            Expanded(
                child: Column(children: [
                  const FittedBox(child: Text('Carbs', style: TextStyle(color: appTheme, fontSize: 20))),
                  NumberPicker(
                    value: nutrients['carbs']!,
                    minValue: 0,
                    maxValue: 500,
                    itemHeight: 30,
                    selectedTextStyle: const TextStyle(color: appTheme, fontSize: 22),
                    onChanged: (value) => setState(() =>  nutrients['carbs'] = value),
                  )
                ])
            ),
            SizedBox(width: 0.05 * width),
            Expanded(
                child: Column(children: [
                  const FittedBox(child: Text('Fats', style: TextStyle(color: appTheme, fontSize: 20))),
                  NumberPicker(
                    value: nutrients['fats']!,
                    minValue: 0,
                    maxValue: 500,
                    itemHeight: 30,
                    selectedTextStyle: const TextStyle(color: appTheme, fontSize: 22),
                    onChanged: (value) => setState(() =>  nutrients['fats'] = value),
                  )
                ])
            )
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
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 40, 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: appTheme,
                        side: BorderSide(
                            width: 2.0, color: Colors.black.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        fixedSize: Size(width * 0.25, height * 0.010),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                      createMealDialog(context, null, null).then((value) =>
                          _addButtonWidget(
                              "${value?.elementAt(0)}", height, width)

                        //_buildButton("${value?.elementAt(0)}", height, width)
                      );

                      //Navigator.pushNamed(context, mealAddRoute);
                    },
                    child: const Text("Add Meal"),
                  )),
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
      barrierDismissible: false,
      //useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Dialog(
              insetPadding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 0,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: height * 0.012,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: _buildMealName(height),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: _buildContents(height),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(["", ""]);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text('CANCEL',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: appTheme,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                )),
                            TextButton(
                              onPressed: () {
                                // todo if we don't add anything
                                if (mealNameController.text.isEmpty ||
                                    mealIngredientsController.text.isEmpty) {
                                  Navigator.of(context).pop(["", ""]);
                                  const snackBar = SnackBar(
                                      content: Text(
                                          'You must fill all the fields, adding meal failed'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  if (index == -1) {
                                    /// Create
                                    if (mealNameController.text.toString() !=
                                        "") {
                                      _mealNames.add(
                                          mealNameController.text.toString());
                                      _mealIngredients.add(
                                          mealIngredientsController.text
                                              .toString());
                                    }
                                  } else if (index != -1) {
                                    /// Edit
                                    _mealNames[index] =
                                        mealNameController.text.toString();
                                    _mealIngredients[index] =
                                        mealIngredientsController.text
                                            .toString();
                                    _updateButtonWidget(
                                        mealNameController.text.toString(),
                                        mealIngredientsController.text
                                            .toString(),
                                        height,
                                        width,
                                        index);
                                  }
                                  Navigator.of(context).pop([
                                    mealNameController.text.toString(),
                                    mealIngredientsController.text.toString()
                                  ]);
                                }
                              },
                              child: const Text('OK',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: appTheme,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )
                          ]),
                    ),
                  ])),
        );
      },
    );
  }

  Future _fileFromImageUrl() async {
    if (post_data.data()!['image_url'] != null) {
      var rng = Random();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = File('$tempPath${rng.nextInt(100)}.png');
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
    mealPlanNameController.text=post_data.data()!['title']!;
    descriptionController.text=post_data.data()!['description']!;
    if(firsttime==0) {
      _fileFromImageUrl();
      firsttime++;
    }
    _goals[0]=post_data.data()!['goals']![0];
    _goals[1]=post_data.data()!['goals']![1];
    _goals[2]= post_data.data()!['goals']![2];
    _goals[3]=post_data.data()!['goals']![3];
    nutrients['calories'] = post_data.data()!['meals_contents']![0];
    nutrients['proteins'] = post_data.data()!['meals_contents']![1];
    nutrients['carbs'] = post_data.data()!['meals_contents']![2];
    nutrients['fats'] = post_data.data()!['meals_contents']![3];

    loseWeight = post_data.data()!['goals']![0] as bool;
    gainMuscle = post_data.data()!['goals']![1] as bool;
    gainWeight = post_data.data()!['goals']![2] as bool;
    maintainHealth = post_data.data()!['goals']![3] as bool;
  }
// todo to check what happens when we don't add anything
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    var timestamp=post_data.data()!['createdAt']!;
    if (_mealNames.isEmpty && !_alreadyfilled ) {
      _alreadyfilled=true;
      for (int i = 0; i < post_data["meals_name"].length; i++) {
        _mealNames.add(post_data["meals_name"][i] as String);
        _mealIngredients.add(post_data["meals_ingredients"][i] as String);
        _addButtonWidget(post_data["meals_name"][i], height, width);
      }
    }


    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Edit meal plan',
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
                          final String title = mealPlanNameController.text;
                          final String description =
                              descriptionController.text;

                          _mealsContents[0] = nutrients['calories']!;
                          _mealsContents[1] = nutrients['proteins'];
                          _mealsContents[2] = nutrients['carbs'];
                          _mealsContents[3] = nutrients['fats'];

                          if (loseWeight! ||
                              gainMuscle! ||
                              gainWeight! ||
                              maintainHealth!) {
                            selectedGoal = true;
                          }
                          if (title == "" || description == "" || selectedGoal == false || _mealNames.isEmpty) {
                            const snackBar = SnackBar(
                                content: Text('You must fill all the fields and add meals'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            await _postManager.deletePost(post_data.id);
                            bool isSubmitted =
                            await _postManager.updateMealPlan(
                                title: title,
                                description: description,
                                timeStamp: timestamp,
                                postImage: _postImageFile,
                                goals: _goals,
                                mealsContents: _mealsContents,
                                mealsName: _mealNames,
                                mealsIngredients: _mealIngredients);
                            setState(() {
                              _isLoading = false;
                            });

                            if (isSubmitted) {
                              const snackBar = SnackBar(content: Text('MealPlan edited successfully'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              Navigator.pop(context);
                            } else {
                              const snackBar = SnackBar(content: Text('There was a problem logging you in'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    child: _buildmealPlanName(height),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
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
                          const SizedBox(height: 4),
                          Text(photo, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ]),
          )),
      resizeToAvoidBottomInset: true,
    );
  }
}
