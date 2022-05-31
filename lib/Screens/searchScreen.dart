import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/database.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class search extends StatefulWidget {
  final String searchHint;
  final String searchContent;
  final ValueChanged<String> onChanged;


  const search({required this.searchHint, required this.searchContent, required this.onChanged, Key? key}) : super(key: key);

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  final searchController = TextEditingController();
  var hide = false;

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
        controller: searchController,
        onChanged: (text) {
          setState(() {
            widget.onChanged(text);
          });
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: appTheme),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  child: const Icon(Icons.close, color: appTheme),
                  onTap: () {
                    searchController.clear();
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
  List<SearchModel> allUsers = [];
  List<SearchModel> users = [];

  String query = '';
  final searchController = TextEditingController();

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
        controller: searchController,
        onChanged: (text) {
          setState(() {});
        },
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: appTheme),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  child: Icon(Icons.close, color: appTheme),
                  onTap: () {
                    searchController.clear();
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

  Widget buildUser(SearchModel model) => ListTile(
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

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    FirebaseDB().getUsers().then((value) => allUsers = value);

    return DefaultTabController(
        length: 1,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text('Search')/*,
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
              ]*/,
              bottom: const TabBar(tabs: [
                Tab(
                  child: Text('Users',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),/*
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
                            fontWeight: FontWeight.bold, fontSize: 15)))*/
              ]),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    search(searchHint: 'Search users',searchContent: searchController.text, onChanged: searchUser,),
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
                /*
                Column(
                  children: [
                    _buildSearch('Search Blog posts',),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.75,
                      indent: width * 0.05,
                      endIndent: width * 0.05,
                    )
                  ],
                ),
                Column(
                  children: [
                    _buildSearch('Search Meals posts'),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.75,
                      indent: width * 0.05,
                      endIndent: width * 0.05,
                    )
                  ],
                ),
                Column(children: [
                  _buildSearch('Search Workouts Posts'),
                  Divider(
                    color: Colors.grey,
                    height: 0,
                    thickness: 0.75,
                    indent: width * 0.05,
                    endIndent: width * 0.05,
                  ),
                ])*/
              ],
            )));
  }
}
