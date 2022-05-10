import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/constants.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/book.dart';
import 'package:yourfitnessguide/utils/book_data.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

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
  Object? get searchContent => this.searchContent;
  final appTheme = const Color(0xff4CC47C);

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    final appTheme = const Color(0xff4CC47C);
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
          icon: Icon(Icons.search, color: appTheme),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  child: Icon(Icons.close, color: appTheme),
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
  final appTheme = const Color(0xff4CC47C);
  double height = 10;
  double width = 10;
  List<Book> books = allBooks;
  String query = '';
  final searchController = TextEditingController();
  var user;


  @override
  void initState(){
    super.initState();
    init();
  }

  Future init() async{
    user.getUsers().then((result) {print(result);});

  }

  Widget _buildSearch(String Title) {
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    user = Provider.of<AuthRepository>(context);

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

  Widget buildBook(Book book) => ListTile(
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
                        image: book.urlImage == null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.asset(
                                        'images/decorations/mclovin.png')
                                    .image)
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(book.urlImage)))),
                SizedBox(
                  width: width * 0.02,
                ),
                Text(book.title)
              ],
            ),
            SizedBox(height: height * 0.02),
          ])));


  void searchUser(String searchContent){
    print(searchContent);
    final users = allBooks.where((book) {
      final titleLower = book.title.toLowerCase();
      final searchContentLower = searchContent.toLowerCase();
      return titleLower.contains(searchContentLower);
    }).toList();
    setState(() {
      this.books = users;
      this.query = searchContent;
    });
  }

  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return DefaultTabController(
        length: 4,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Search'),
              actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, homeRoute);
                            },
                            icon: Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                            ))
                      ],
                    )),
              ],
              bottom: TabBar(tabs: [
                Tab(
                  child: Text('Users',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Tab(
                  child: Text('Plogs',
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
                Container(
                  child: Column(
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
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return buildBook(book);
                        },
                      ))
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      _buildSearch('Search Plog posts',),
                      Divider(
                        color: Colors.grey,
                        height: 0,
                        thickness: 0.75,
                        indent: width * 0.05,
                        endIndent: width * 0.05,
                      )
                    ],
                  ),
                ),
                Container(
                  child: Column(
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
                ),
                Container(
                  child: Column(children: [
                    _buildSearch('Search Workouts Posts'),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.75,
                      indent: width * 0.05,
                      endIndent: width * 0.05,
                    ),
                  ]),
                )
              ],
            )));
  }
}
