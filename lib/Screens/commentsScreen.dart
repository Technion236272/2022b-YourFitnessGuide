import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/managers/comments_manager.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/database.dart';
import '../utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({Key? key, required this.postId})
      : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState(
        postId: this.postId,
      );
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final CommentsManager _commentsManager = CommentsManager();
  bool isButtonActive=false;

  _CommentsScreenState({
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var user = Provider.of<AuthRepository>(context);
    commentController.addListener(() {
      final isButtonActive=commentController.text.isNotEmpty;
      setState(()=>this.isButtonActive=isButtonActive);

    });

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Post Comments'),
        ),
        body: Column(children: [
          Expanded(child: buildComments(height, width)),
          //  Divider(),
          Visibility(
            visible: user.isAuthenticated,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  color: Colors.white,
                ),
                child: ListTile(
                    title: TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Write a comment ...",
                        hintStyle: TextStyle(height: 1, fontSize: 15, color: Colors.grey),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

              ),
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200.0)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: appTheme,
                            side: const BorderSide(color: Colors.grey),
                            //shadowColor: Colors.black, //appTheme,
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            fixedSize: Size(width * 0.2, height * 0.04),
                            textStyle: const TextStyle(fontSize: 14, color: Colors.white)
                        ),
                        onPressed: isButtonActive ?
                            () {
                          if (commentController.text.toString().isEmpty) {
                            const snackBar = SnackBar(content: Text('You must enter a comment'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          } else {
                            addComment();
                          }
                        }
                        : null,
                        child: const Text("Post"),
                      )
                  ),
                ),
            ),
          )
        ]));
  }


  addComment() async {
    await _commentsManager.addComment(postId, commentController.text.toString());
    commentController.clear();
  }

  Widget buildComments(double height, double width) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>?>>(
      stream: _commentsManager.getComments(postId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 10),
              child: const CircularProgressIndicator.adaptive(value: 0.8));
        }
        List<Comment> comments = [];

        snapshot.data!.docs.forEach((doc) async {
          var tmp = await FirebaseDB().checkUserExists(doc['userId']);
          if (tmp == false) {
            _commentsManager.deleteUserComments(postId, doc['userId']);
          }
        });

        snapshot.data!.docs.forEach((doc) {
          if (doc['timestamp'] != null) {
            comments.add(Comment.fromDocument(doc));
          }
        });
        _commentsManager.updateCommentsNum(postId);

        if (comments.isEmpty) {
          return emptyNote('Post doesn\'t have comments yet', height, width);
        }
        return ListView(
          children: comments,
        );
      },
    );
  }
}

class Comment extends StatelessWidget {
  final String userId;
  final String comment;
  final Timestamp? timestamp;

  Comment({
    required this.userId,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        userId: doc['userId'],
        comment: doc['comment'],
        timestamp: doc['timestamp']);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PostManager().getUserPicAndName(userId),
        builder: (context, AsyncSnapshot<Map<String, String?>?> snapshot) {
          if (snapshot.hasData &&
              snapshot.data!['name'] != null &&
              snapshot.data!['picture'] != null) {
            return Column(
              children: [
                ListTile(
                    title: GestureDetector(
                      onTap: () {
                        SearchArguments arg = SearchArguments(uid: userId, isUser: true);
                        Navigator.pushNamed(context, '/profile', arguments: arg);
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: Text(
                            snapshot.data!['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                      )
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        SearchArguments arg = SearchArguments(uid: userId, isUser: true);
                        Navigator.pushNamed(context, '/profile', arguments: arg);
                      },
                      child: CircleAvatar(radius: 25, backgroundImage: NetworkImage(snapshot.data!['picture']!)),
                    ),
                    subtitle: Container(
                        margin: const EdgeInsets.only(top: 2),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment, style: const TextStyle(fontSize: 18)),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(timeago.format(timestamp!.toDate()))
                                ]
                            ),
                          ],
                        ))
                ),
                const Divider(thickness: 1),
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
