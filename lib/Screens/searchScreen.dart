import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:yourfitnessguide/utils/post.dart';

class SearchBar extends StatefulWidget {
  final String searchHint;
  final ValueChanged<String> onChanged;


  const SearchBar({required this.searchHint,required this.onChanged, Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final searchUserController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: searchUserController,
        onChanged: (text) {
          setState(() {
            widget.onChanged(text);
          });
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: appTheme),
          suffixIcon: searchUserController.text.isNotEmpty
              ? GestureDetector(
            child: const Icon(Icons.close, color: appTheme),
            onTap: () {
              searchUserController.clear();
              widget.onChanged('');
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )
              : null,
          hintText: widget.searchHint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}


class _SearchScreenState extends State<SearchScreen> {
  double height = 10;
  double width = 10;
  List<SearchUserModel> allUsers = [];
  List<SearchUserModel> users = [];
  List<Post> allPosts = [];
  List<Post> posts = [];
  List<Post> allMeals = [];
  List<Post> allBlogs = [];
  List<Post> blogs = [];
  List<Post> meals = [];
  List<Post> allWorkouts = [];
  List<Post> workouts = [];
  final List<bool?> _workoutGoals = [false, false, false, false];
  final List<bool?> _mealPlanGoals = [false, false, false, false];
  String query = '';
  String? dropdownValueWorkout;
  String? dropdownValuemealPlan;
  final searchUserController = TextEditingController();
  RangeValues kcalrange= RangeValues((0), 5000);
  RangeValues protiensrange= RangeValues((0), 500);
  RangeValues carbsrange= RangeValues((0), 500);
  RangeValues fatsrange= RangeValues((0), 500);
  final PostManager _postManager = PostManager();

  @override
  void initState(){
    super.initState();
    init();
  }

  Future init() async{
    FirebaseDB().getUsers().then((result) {
      allUsers = List.from(result);
      users = List.from(result);
    });
    PostManager().getPosts().then((value) {
      allPosts = List.from(value);
      posts = List.from(value);

      allBlogs = allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList();
      allMeals = allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList();
      allWorkouts = allPosts.where((element) {return element.data!['category'].startsWith('Workout');}).toList();
      allMeals.sort((post1, post2){
        return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
      });
      allWorkouts = allPosts.where((element) {return element.data!['category'].startsWith('Workout');}).toList();
      allWorkouts.sort((post1, post2){
        return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
      });
      allBlogs = allPosts.where((element) {return element.data!['category'].startsWith('Blog');}).toList();
      allBlogs.sort((post1, post2){
        return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
      });
      blogs = allBlogs;
      meals = allMeals;
      workouts = allWorkouts;


    });

  }
  Future openFilterDialogWorkout() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
          builder: (context, setStatee) => AlertDialog(
            title: const Center(child: Text('Workout Filter Options'),),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment : CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Timerange",
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 25, 0),
                        child: DropdownButton<String>(
                          value: dropdownValueWorkout,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setStatee(() {
                              dropdownValueWorkout = newValue!;
                            });
                          },
                          items: <String>['a day ago', '5 days ago', '10 days ago', '15 days ago','a month ago']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Workout goal",
                    style: TextStyle(
                      color: appTheme,
                      fontSize: 17,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  CheckboxListTile(
                      title: const Text('Lose Weight' ,style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _workoutGoals[0],
                      //groupValue: userGoal,
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _workoutGoals[0] = value;
                      })),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.5,
                    indent: width * 0.05,
                    endIndent: width * 0.1,
                  ),
                  CheckboxListTile(
                      title: const Text('Gain Muscle',style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _workoutGoals[1],
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _workoutGoals[1] = value;
                      })),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.5,
                    indent: width * 0.05,
                    endIndent: width * 0.1,
                  ),
                  CheckboxListTile(
                      title: const Text('Gain Healthy Weight',style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _workoutGoals[2],
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _workoutGoals[2] = value;
                      })),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.5,
                    indent: width * 0.05,
                    endIndent: width * 0.1,
                  ),
                  CheckboxListTile(
                      title: const Text('Maintain Healthy Lifestyle',style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _workoutGoals[3],
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _workoutGoals[3] = value;
                      })),
                ],
              ),
            ),
            actions: [
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setStatee(() =>
                          dropdownValueWorkout=dropdownValueWorkout);
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: appTheme,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      )
                    ]),
              )
            ],
          )));
  Future openFilterDialogMealplan() => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStatee) => AlertDialog(
            title: const Center(child: Text('Meal Plan Filter Options'),),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment : CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Timerange",
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 25, 0),
                        child: DropdownButton<String>(
                          value: dropdownValuemealPlan,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setStatee(() {
                              dropdownValuemealPlan = newValue!;
                            });
                          },
                          items: <String>['a day ago', '5 days ago', '10 days ago', '15 days ago','a month ago']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Workout goal",
                    style: TextStyle(
                      color: appTheme,
                      fontSize: 17,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  CheckboxListTile(
                      title: const Text('Lose Weight' ,style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _mealPlanGoals[0],
                      //groupValue: userGoal,
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _mealPlanGoals[0] = value;
                      })),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.5,
                    indent: width * 0.05,
                    endIndent: width * 0.1,
                  ),
                  CheckboxListTile(
                      title: const Text('Gain Muscle',style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _mealPlanGoals[1],
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _mealPlanGoals[1] = value;
                      })),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.5,
                    indent: width * 0.05,
                    endIndent: width * 0.1,
                  ),
                  CheckboxListTile(
                      title: const Text('Gain Healthy Weight',style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _mealPlanGoals[2],
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _mealPlanGoals[2] = value;
                      })),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.5,
                    indent: width * 0.05,
                    endIndent: width * 0.1,
                  ),
                  CheckboxListTile(
                      title: const Text('Maintain Healthy Lifestyle',style: TextStyle(
                        fontSize: 14,
                      ),),
                      value: _mealPlanGoals[3],
                      activeColor: appTheme,
                      onChanged: (value) => setStatee(() {
                        _mealPlanGoals[3] = value;
                      })),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Specify Kcal",
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        child:  RangeSlider(
                          min: 0,
                          max: 5000,
                          activeColor: appTheme,
                          divisions: 50,
                          values:kcalrange,
                          onChanged:  (values){
                            setStatee(() {
                              kcalrange =values;
                            });
                          },
                          labels: RangeLabels('${kcalrange.start}','${kcalrange.end}'),

                        ),
                      ),


                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Specify Proteins",
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        child:  RangeSlider(
                          activeColor: appTheme,
                          min: 0,
                          max: 500,
                          divisions: 500,
                          values: protiensrange,
                          onChanged:  (values){
                            setStatee(() {
                              protiensrange =values;
                            });
                          },
                          labels: RangeLabels('${protiensrange.start}','${protiensrange.end}'),



                        ),
                      ),


                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Specify Carbs",
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        child:  RangeSlider(
                          activeColor: appTheme,
                          min: 0,
                          max: 500,
                          divisions: 500,
                          values: carbsrange,
                          onChanged:  (values){
                            setStatee(() {
                              carbsrange =values;
                            });
                          },
                          labels: RangeLabels('${carbsrange.start}','${carbsrange.end}'),


                        ),
                      ),


                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Specify Fats",
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Container(
                        child:  RangeSlider(
                          min: 0,
                          max: 500,
                          activeColor: appTheme,
                          divisions: 500,
                          values: fatsrange,
                          onChanged:  (values){
                            setStatee(() {
                              fatsrange =values;
                            });
                          },
                          labels: RangeLabels('${fatsrange.start}','${fatsrange.end}'),

                        ),
                      ),


                    ],
                  )

                ],
              ),
            ),
            actions: [
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setStatee(() =>dropdownValuemealPlan=dropdownValuemealPlan);
                          Navigator.of(context).pop();


                        },
                        child: const Text('OK',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: appTheme,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      )
                    ]),
              )
            ],
          )));


  Widget buildUser(SearchUserModel model) => ListTile(
      onTap: () {
        SearchArguments arg = SearchArguments(uid: model.uid!, isUser: false);
        Navigator.pushNamed(context, '/profile', arguments: arg);
      },
      title: Container(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          child: Column(children: [
            Row(
              children: [
                Container(
                    width: height * 0.06,
                    height: height * 0.06,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 3,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1))
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: model.picture.image))),
                SizedBox(width: width * 0.02),
                Text(model.name!)
              ],
            ),
            SizedBox(height: height * 0.02),
          ])));

  Widget buildPost(SearchUserModel model) => ListTile(
      onTap: () {
        SearchArguments arg = SearchArguments(uid: model.uid!, isUser: false);
        Navigator.pushNamed(context, '/profile', arguments: arg);
      },
      title: Container(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          child: Column(children: [
            Row(
              children: [
                Container(
                    width: height * 0.06,
                    height: height * 0.06,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 3,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1))
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: model.picture.image))),
                SizedBox(
                  width: width * 0.02,
                ),
                Text(model.name!)
              ],
            ),
            SizedBox(height: height * 0.02),
          ])));


  void searchUser(String searchContent){

    final filteredUsers = allUsers.where((user) {
      final titleLower = user.name!.toLowerCase();
      final searchContentLower = searchContent.toLowerCase();
      return titleLower.contains(searchContentLower);
    }).toList();
    setState(() {
      users = filteredUsers;
      query = searchContent;
    });
  }

  void searchBlog(String searchContent){
    allBlogs = allPosts.where((element) {return element.data!['category'].startsWith('Blog');}).toList();
    allBlogs.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    final filteredPosts = allBlogs.where((post) {
      final titleLower = post.data!['title'].toLowerCase();
      final searchContentLower = searchContent.toLowerCase();
      return titleLower.contains(searchContentLower);
    }).toList();
    setState(() {
      blogs = filteredPosts;
      query = searchContent;
    });
  }

  void searchMeal(String searchContent){
    allMeals = (allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList());
    allMeals.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    _filterTimeRangeMeal(context, dropdownValuemealPlan ??'nothing');
    _filterMealGoals(context);
    _filterMealContents(context);
    final filteredPosts = allMeals.where((post) {
      final titleLower = post.data!['title'].toLowerCase();
      final searchContentLower = searchContent.toLowerCase();
      return titleLower.contains(searchContentLower);
    }).toList();
    setState(() {
      meals = filteredPosts;
      query = searchContent;
    });
  }

  void searchWorkout(String searchContent){
    allWorkouts = allPosts.where((element) {return element.data!['category'].startsWith('Workout');}).toList();
    allWorkouts.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    _filterTimeRangeWorkout(context, dropdownValueWorkout??'nothing');
    _filterWorkoutGoals(context);
    final filteredPosts = allWorkouts.where((post) {
      final titleLower = post.data!['title'].toLowerCase();
      final searchContentLower = searchContent.toLowerCase();
      return titleLower.contains(searchContentLower);
    }).toList();
    setState(() {
      workouts = filteredPosts;
      query = searchContent;
    });
  }

  _filterWorkoutGoals(BuildContext context)
  {
    allWorkouts = allPosts.where((element) {return element.data!['category'].startsWith('Workout');}).toList();
    allWorkouts.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    _filterTimeRangeWorkout(context, dropdownValueWorkout ??'nothing');
    if(_workoutGoals[0]==false && _workoutGoals[1]==false && _workoutGoals[2]==false&&
        _workoutGoals[3]==false)
    {}
    else {
      allWorkouts = (allWorkouts.where((element) {
        List<dynamic> postGoals = element.data!['goals'];

        return postGoals[0] == _workoutGoals[0] &&
            postGoals[1] == _workoutGoals[1]
            && postGoals[2] == _workoutGoals[2] &&
            postGoals[3] == _workoutGoals[3];
      }).toList());
    }
    workouts=allWorkouts;
  }

  _filterTimeRangeWorkout(BuildContext context,String? timerange)
  {
    allWorkouts = allPosts.where((element) {return element.data!['category'].startsWith('Workout');}).toList();
    allWorkouts.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    allWorkouts = (allWorkouts.where((element) {
      if(timerange=='a day ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 1));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='5 days ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 5));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='10 days ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 10));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='15 days ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 15));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='a month ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 30));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      return true;}).toList());



    workouts=allWorkouts;
  }

  _filterMealGoals(BuildContext context)
  {
    allMeals = allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList();
    allMeals.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    _filterTimeRangeMeal(context, dropdownValuemealPlan ??'nothing');
    if(_mealPlanGoals[0]==false && _mealPlanGoals[1]==false && _mealPlanGoals[2]==false&&
        _mealPlanGoals[3]==false)
    {}
    else {
      allMeals = (allMeals.where((element) {
        List<dynamic> postGoals = element.data!['goals'];

        return postGoals[0] == _mealPlanGoals[0] &&
            postGoals[1] == _mealPlanGoals[1]
            && postGoals[2] == _mealPlanGoals[2] &&
            postGoals[3] == _mealPlanGoals[3];
      }).toList());
    }
    meals=allMeals;
  }
  _filterMealContents(BuildContext context)
  {
    allMeals = allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList();
    allMeals.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    _filterMealGoals(context);
    allMeals = (allMeals.where((element) {
      List<dynamic> mealContents = element.data!['meals_contents'];

      return mealContents[0] >= kcalrange.start && mealContents[0] <= kcalrange.end &&
          mealContents[1] >= protiensrange.start && mealContents[1] <= protiensrange.end &&
          mealContents[2] >= carbsrange.start && mealContents[2] <= carbsrange.end &&
          mealContents[3] >= fatsrange.start && mealContents[3] <= fatsrange.end ;
    }).toList());
    meals=allMeals;
  }

  _filterTimeRangeMeal(BuildContext context,String? timerange)
  {
    allMeals = allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList();
    allMeals.sort((post1, post2){
      return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
    });
    allMeals = (allMeals.where((element) {
      if(timerange=='a day ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 1));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='5 days ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 5));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='10 days ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 10));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='15 days ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 15));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      if(timerange=='a month ago') {
        DateTime time = DateTime.now().subtract(Duration(days: 30));
        DateTime postCreationTime =element.data!['createdAt'].toDate();
        return postCreationTime.isAfter(time);
      }
      return true;}).toList());

    meals=allMeals;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    FirebaseDB().getUsers().then((value) => allUsers = value);
    PostManager().getPosts().then((value) {
      allPosts = List.from(value);
      allMeals = (allPosts.where((element) {return element.data!['category'].startsWith('Meal Plan');}).toList());
      allMeals.sort((post1, post2){
        return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
      });
      allWorkouts = allPosts.where((element) {return element.data!['category'].startsWith('Workout');}).toList();
      allWorkouts.sort((post1, post2){
        return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
      });
      allBlogs = allPosts.where((element) {return element.data!['category'].startsWith('Blog');}).toList();
      allBlogs.sort((post1, post2){
        return post2.data!['createdAt'].toDate().compareTo(post1.data!['createdAt'].toDate());
      });
    });




    return DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text('Search'),
              actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [

                      ],
                    )),
              ],
              bottom: const TabBar(tabs: [
                Tab(
                  child: Text('Users',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Tab(
                  child: Text('Blogs',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Tab(
                    child: Text('Meals',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15))),
                Tab(
                    child: Text('Workouts',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)))
              ]),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    SearchBar(searchHint: 'Search users', onChanged: searchUser,),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.75,
                      indent: width * 0.05,
                      endIndent: width * 0.05,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return buildUser(user);
                          },
                        ))
                  ],
                ),
                Column(
                  children: [
                    SearchBar(searchHint: 'Search Blog Posts', onChanged: searchBlog),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.75,
                      indent: width * 0.05,
                      endIndent: width * 0.05,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: blogs.length,
                          itemBuilder: (context, index) {
                            final post = blogs[index];
                            return post;
                          },
                        )),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded (child: SearchBar(searchHint: 'Search Meals posts', onChanged: searchMeal)),
                        IconButton(
                            onPressed: () async {

                              await openFilterDialogMealplan();
                              setState(() {
                                _filterTimeRangeMeal(context, dropdownValuemealPlan ??'nothing');
                                _filterMealGoals(context);
                                _filterMealContents(context);

                              });
                            },
                            icon: const Icon(
                              Icons.filter_alt,
                              color: appTheme,
                            )),
                      ],
                    ),

                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.75,
                      indent: width * 0.05,
                      endIndent: width * 0.05,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: meals.length,
                          itemBuilder: (context, index) {
                            final post = meals[index];
                            return post;
                          },
                        )),
                  ],
                ),
                Column(children: [

                  Row(
                    children: [
                      Expanded(child: SearchBar(searchHint: 'Search Workouts Posts', onChanged: searchWorkout)),
                      IconButton(
                          onPressed: () async {
                            await openFilterDialogWorkout();
                            setState(() {
                              _filterTimeRangeWorkout(context, dropdownValueWorkout ??'nothing');
                              _filterWorkoutGoals(context);
                            });
                          },
                          icon: const Icon(
                            Icons.filter_alt,
                            color: appTheme,
                          ))
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.75,
                    indent: width * 0.05,
                    endIndent: width * 0.05,
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final post = workouts[index];
                          return post;
                        },
                      )

                  )

                ])
              ],
            )));
  }
}