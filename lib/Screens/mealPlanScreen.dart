import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final appTheme = const Color(0xff4CC47C);
  TextEditingController mealPlanNameController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
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
  final List<String?> _mealNames = [];
  final List<String?> _mealIngredients = [];
  final List<Widget> _list = [];
  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 0.1, //                   <--- border width here
      ),
    );
  }

  Widget _buildButton(String Name, double height, double width) {
    int index = _mealNames.indexOf(Name);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //margin: const EdgeInsets.all(5),
              //padding: const EdgeInsets.all(5),
              child: TextButton(
                child: Text("$Name", textAlign: TextAlign.left),
                style: TextButton.styleFrom(
                    primary: appTheme,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(0)),
                    fixedSize: Size(width * 0.3, height * 0.010),
                    textStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    )),
                onPressed: () {},
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
                  child: Container(
                    child: ElevatedButton(
                      child: Text("More"),
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff84C59E),
                          shadowColor: appTheme,
                          elevation: 0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(0.0)),
                          fixedSize: Size(width * 0.2, height * 0.010),
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
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                iconSize: 30,
                color: Colors.red,
                //splashColor: Colors.purple,
                onPressed: () {
                  setState(() {
                    index = _mealNames.indexOf(Name);
                    // print(index);
                    //print(_mealNames);
                    if (index != -1) {
                      _deleteButtonWidget(index);
                      // print(_mealNames);
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
      String name,String Ingredients, double height, double width, int index) {
    setState(() {
      if (name != "") {
        _mealNames[index]=name;
        _mealIngredients[index]=Ingredients;
        _list[index] = _buildButton(name, height, width);
      }
      else {

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
              Text(
                "Plan name",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.name,
                controller: mealPlanNameController,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Meal title",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.name,
                controller: mealNameController,
                textAlign: TextAlign.left,
                /*decoration: InputDecoration(
                  focusedBorder:OutlineInputBorder(
                    borderSide: const BorderSide( width: 1.0),
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),

                 */
              )
            ],
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Ingredients",
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
                controller: mealIngredientsController,
                textAlign: TextAlign.left,
                /* decoration: InputDecoration(
                  focusedBorder:OutlineInputBorder(
                    borderSide: const BorderSide( width: 1.0),
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),

                */
              )
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
              'images/icons/exercises.png',
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
                        primary: Color(0xff84C59E),
                        shadowColor: appTheme,
                        elevation: 17,
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

                                  if(mealNameController.text.toString()!="") {
                                    _mealNames
                                        .add(
                                        mealNameController.text.toString());
                                    _mealIngredients.add(
                                        mealIngredientsController
                                            .text
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              )
            ]),
      )),
      resizeToAvoidBottomInset: true,
    );
  }
}
