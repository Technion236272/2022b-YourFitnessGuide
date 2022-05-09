
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/constants.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final appTheme = const Color(0xff4CC47C);
  TextEditingController mealPlanNameController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  TextEditingController KcalController = TextEditingController();
  TextEditingController ProtiensController = TextEditingController();
  TextEditingController CarbsController = TextEditingController();
  TextEditingController FatsController = TextEditingController();
  bool? loseWeight = false;
  bool? gainMuscle = false;
  bool? gainWeight = false;
  bool? maintainHealth = false;
  final List<TextEditingController> _controllerInput = [];
  final List<TextField> _textFieldInput = [];
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
            mainAxisAlignment: MainAxisAlignment.end,
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
            /*  Container(
                  padding: const EdgeInsets.fromLTRB(50, 8, 40, 10),
                  child: ElevatedButton(
                    child: const Text("Add BreakFast"),
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xff84C59E),
                        shadowColor: appTheme,
                        elevation: 1,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(0)),
                        fixedSize: Size(width * 0.4, height * 0.040),
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                    },
                  )),
              Container(
                  padding: const EdgeInsets.fromLTRB(50, 8, 40, 10),
                  child: ElevatedButton(
                    child: const Text("Add Launch"),
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xff84C59E),
                        shadowColor: appTheme,
                        elevation: 1,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(0)),
                        fixedSize: Size(width * 0.4, height * 0.040),
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                    },
                  )),
              Container(
                  padding: const EdgeInsets.fromLTRB(50, 8, 40, 10),
                  child: ElevatedButton(
                    child: const Text("Add dinner"),
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xff84C59E),
                        shadowColor: appTheme,
                        elevation: 1,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(0)),
                        fixedSize: Size(width * 0.4, height * 0.040),
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                    },
                  )),

             */
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
                        fixedSize: Size(width * 0.3, height * 0.040),
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        )),
                    onPressed: () {
                      Navigator.pushNamed(context, mealAddRoute);
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
          'Create a meal plan',
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
      ),

      resizeToAvoidBottomInset: true,
    );
  }

}
