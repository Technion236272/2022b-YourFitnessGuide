import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/database.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class search extends StatefulWidget {
  final String searchHint;
  final ValueChanged<String> onChanged;


  const search({required this.searchHint,required this.onChanged, Key? key}) : super(key: key);

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
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

class _SearchScreenState extends State<SearchScreen> {
  double height = 10;
  double width = 10;
  List<SearchUserModel> allUsers = [];
  List<SearchUserModel> users = [];
  List<post> allPosts = [];
  List<post> posts = [];
  List<post> allMeals = [];
  List<post> allBlogs = [];
  List<post> blogs = [];
  List<post> meals = [];
  List<post> allWorkouts = [];
  List<post> workouts = [];

  String query = '';
  final searchUserController = TextEditingController();

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

  Widget _buildSearch(String Title) {

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
          setState(() {});
        },
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: appTheme),
          suffixIcon: searchUserController.text.isNotEmpty
              ? GestureDetector(
            child: Icon(Icons.close, color: appTheme),
            onTap: () {
              searchUserController.clear();
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )
              : null,
          hintText: Title,
          border: InputBorder.none,
        ),
      ),
    );
  }

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
                        image: model.pictureUrl == null
                            ? DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                                'images/decorations/mclovin.png')
                                .image)
                            : DecorationImage(
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
                        image: model.pictureUrl == null
                            ? DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                                'images/decorations/mclovin.png')
                                .image)
                            : DecorationImage(
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
   // print(PostManager().getPostByID('vL85d9242g3ViA6ts11E'));


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
                        IconButton(
                            onPressed: () {
                              const snackBar = SnackBar(content: Text('Filtering options coming soon'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                            icon: const Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                            ))
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
                    search(searchHint: 'Search users', onChanged: searchUser,),
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
                    search(searchHint: 'Search Blog Posts', onChanged: searchBlog),
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
                    search(searchHint: 'Search Meals posts', onChanged: searchMeal),
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
                  search(searchHint: 'Search Workouts Posts', onChanged: searchWorkout),
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
                      )),
                ])
              ],
            )));
  }
}