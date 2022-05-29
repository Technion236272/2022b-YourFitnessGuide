import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'dart:io';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  TextEditingController mealPlanNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController mealNameController = TextEditingController();
  TextEditingController mealIngredientsController = TextEditingController();
  TextEditingController KcalController = TextEditingController();
  TextEditingController ProtiensController = TextEditingController();
  TextEditingController CarbsController = TextEditingController();
  TextEditingController FatsController = TextEditingController();
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  final List<bool?> _goals = [false, false, false, false];
  bool selectedGoal = false;
  final List<String?> _mealNames = [];
  final List<String?> _mealIngredients = [];
  final List<Widget> _list = [];
  final List<int> _mealsContents = [0, 0, 0, 0];
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
                child: Text("$Name", textAlign: TextAlign.left,style: TextStyle(color: appTheme)),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    //side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(0)),
                    fixedSize: Size(width * 0.25, height * 0.010),
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: appTheme,
                    )),
                onPressed: () {},
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Container(
                    child: ElevatedButton(
                      child: Text("More"),
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff84C59E),
                          side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(0.0)),
                          fixedSize: Size(width * 0.17, height * 0.010),
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: appTheme,
                          )),
                      onPressed: () {
                        index = _mealNames.indexOf("$Name");
                        String? meal_name = _mealNames.elementAt(index);
                        String? meal_ingredient =
                            _mealIngredients.elementAt(index);
                        createMealDialog(context, meal_name, meal_ingredient);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: ElevatedButton(
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
                style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(0.0)),
                    fixedSize: Size(width * 0.05, height * 0.010),
                    textStyle: TextStyle(
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
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  label: false
                      ? Center(
                    child: Text("Plan name"),
                  )
                      : Text("Plan name"),
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
          child: TextField(
            controller: mealNameController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 5),
              label: Text("Meal Title"),
              hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
              labelStyle: TextStyle(
                color: appTheme,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
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
          child: TextField(
            minLines: 1,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            controller: mealIngredientsController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 5),
              label: Text("Ingredients"),
              hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
              labelStyle: TextStyle(
                color: appTheme,
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
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

  Widget _buildMealContents(double height, double width) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                labelText: "Kcal",
                labelStyle: TextStyle(
                  color: appTheme,
                  fontSize: 21,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: KcalController,
            )),
            SizedBox(
              width: 0.05 * width,
            ),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 5),
                  labelText: "Proteins",
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 21,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                controller: ProtiensController,
              ),
            ),
            SizedBox(
              width: 0.05 * width,
            ),
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                labelText: "Carbs",
                labelStyle: TextStyle(
                  color: appTheme,
                  fontSize: 21,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: CarbsController,
            )),
            SizedBox(
              width: 0.05 * width,
            ),
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                labelText: "Fats",
                labelStyle: TextStyle(
                  color: appTheme,
                  fontSize: 21,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              controller: FatsController,
            ))
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
              Text(
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
                    child: const Text("Add Meal"),
                    style: ElevatedButton.styleFrom(
                        primary: appTheme,
                        side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        fixedSize: Size(width * 0.25, height * 0.010),
                        textStyle: TextStyle(
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
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(2, 30, 2, 30),
          child: Dialog(
              insetPadding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: height * 0.012,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
                      child: _buildMealName(height),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
                      child: _buildContents(height),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            /* TextButton(
                              onPressed: () {},
                              child: Text('ATTACH PHOTO',
                                  style: TextStyle(
                                    color: appTheme,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),

                            */
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(["", ""]);
                              },
                              child: Text('CANCEL',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: appTheme,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            TextButton(
                              onPressed: () {
                                // todo if we dont add anything
                                if (index == -1) {
                                  if (mealNameController.text.toString() !=
                                      "") {
                                    _mealNames.add(
                                        mealNameController.text.toString());
                                    _mealIngredients.add(
                                        mealIngredientsController.text
                                            .toString());
                                  }
                                } else if (index != -1) {
                                  _mealNames[index] =
                                      mealNameController.text.toString();
                                  _mealIngredients[index] =
                                      mealIngredientsController.text.toString();
                                  _updateButtonWidget(
                                      mealNameController.text.toString(),
                                      mealIngredientsController.text.toString(),
                                      height,
                                      width,
                                      index);
                                }
                                Navigator.of(context).pop([
                                  mealNameController.text.toString(),
                                  mealIngredientsController.text.toString()
                                ]);
                              },
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
                  ])),
        );
      },
    );
  }

// todo to check what happens when we dont add anything
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Create a meal plan',
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
                          final String title = mealPlanNameController.text;
                          final String description = descriptionController.text;
                          final String kcal = KcalController.text;
                          final String protiens = ProtiensController.text;
                          final String carbs = CarbsController.text;
                          final String fats = FatsController.text;

                          if (loseWeight! ||
                              gainMuscle! ||
                              gainWeight! ||
                              maintainHealth!) {
                            selectedGoal = true;
                          }
                          if (title == "" ||
                              description == "" ||
                              kcal == "" ||
                              protiens == "" ||
                              carbs == "" ||
                              fats == "" ||
                              selectedGoal == false ||
                              _mealNames.isEmpty) {
                            const snackBar = SnackBar(
                                content: Text(
                                    'You must fill all the fields and add meals'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            _mealsContents[0] = int.parse(kcal);
                            _mealsContents[1] = int.parse(protiens);
                            _mealsContents[2] = int.parse(carbs);
                            _mealsContents[3] = int.parse(fats);
                            bool isSubmitted = await _postManager.submitMealPlan(
                                title: title,
                                description: description,
                                postImage: _postImageFile,
                                goals: _goals,
                                mealsContents: _mealsContents,
                                mealsName: _mealNames,
                                mealsIngredients: _mealIngredients);
                            setState(() {
                              _isLoading = false;
                            });

                            if (isSubmitted) {
                              const snackBar = SnackBar(
                                  content: Text('Meal Plan posted successfully'));
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
}
