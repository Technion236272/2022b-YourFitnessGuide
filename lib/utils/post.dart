import 'dart:math';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'globals.dart';



class Post extends StatefulWidget {
  AsyncSnapshot? snapshot;
  late int? index;
  bool owner = false;
  late Image? userPicture = null;
  late Image? postImage;
  late String? category = null;
  late String? username = null;
  late DateTime? date = null;
  late int? rating = null;
  late String? title = null;
  late String? screen = null;
  late String? uid = null;
  late Map<String,dynamic>? data = null;
  bool hide = true;
  var user;
  bool? goalFiltered = false;
  //late Map? likes = null;

  Post({Key? key, this.index, this.snapshot, required this.screen, this.goalFiltered, this.uid, this.data})
      : super(key: key) {
    StreamBuilder<Map<String, dynamic>?>(
        stream: PostManager()
            .getUserInfo(data?['user_uid'] ?? snapshot?.data!.docs[index].data()!['user_uid'])
            .asStream(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting && userSnapshot.data == null) {
            return const Center(child: LinearProgressIndicator());
          }
          if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.data == null) {
            return const ListTile();
          }
          userPicture = Image.network(data?['picture'] ?? userSnapshot.data!['picture']!);
          category    = data?['category'] ?? snapshot?.data!.docs[index].data()!['category'];
          username    = data?['name'] ?? userSnapshot.data!['name'];
          title       = data?['title'] ?? userSnapshot.data!['title']!;
          rating      = data?['rating'] ?? userSnapshot.data!['rating'];
          date =
            data != null
              ? (data?['createdAt'].toDate())
              : (snapshot?.data!.docs[index].data()!['createdAt'] != null
                ? snapshot?.data!.docs[index].data()!['createdAt'].toDate()
                : DateTime.now());
          snapshot?.data!.docs[index].data()!['likes'] = {};
          //likes = data?['likes'] ?? snapshot?.data!.docs[index].data()!['likes'];

          return const ListTile();
        });
  }

  @override
  State<Post> createState() => _PostState();


}

class _PostState extends State<Post> {
  ////Map likes;
  //int likeCount;
  bool isUpvoted = false;
  bool isDownvoted = false;
  bool isSaved = false;
  final _postManager = PostManager();

  Widget _buildCommentButton() {
    String? userId;
    String? postId;
    return IconButton(
        onPressed: () {
          postId = widget.data != null
              ? widget.data!['uid']
              : widget.snapshot?.data!.docs[widget.index].id;

          if (getCurrUid() != null) {
            userId = getCurrUid();
          }
          if (postId == null || userId == null) {
            userId = "not relevant";
          }

          if ( userId == "not relevant" ) {
            Future.delayed(const Duration(milliseconds: 1200), () {
              Navigator.pushNamed(context, commentsRoute, arguments: {
                'postId': postId,
                'userId': userId,
              });

            });
          }
          else {
            Navigator.pushNamed(context, commentsRoute, arguments: {
              'postId': postId,
              'userId': userId,
            });
          }
        },
        icon: const Icon(Icons.chat_bubble, color: Colors.grey)
    );
  }

  Widget _buildUpvoteButton(){
    String? userId = getCurrUid();
    String? postId = widget.snapshot?.data!.docs[widget.index].id!;
    String? postOwnerId =  widget.snapshot?.data!.docs[widget.index].data()!['user_uid']!;

    List? upvotesList = widget.snapshot?.data!.docs[widget.index].data()!['upvotes'];
    isUpvoted = upvotesList?.contains(userId) ?? false;

    List? downvotesList = widget.snapshot?.data!.docs[widget.index].data()!['downvotes'];
    isDownvoted = downvotesList?.contains(userId) ?? false;

    return IconButton(
        onPressed: () {
          if (widget.user.isAuthenticated) {
            isUpvoted = !isUpvoted;
            if (isUpvoted && isDownvoted) {
              isDownvoted = false;
              widget.user.modifyVote(postId, postOwnerId, 'downvotes', isDownvoted);
            }
            setState(() {});
            widget.user.modifyVote(postId, postOwnerId, 'upvotes', isUpvoted);

            /// Notification
            ///
            if(isUpvoted) {
              //addUpvoteToNotification(postOwnerId!, postId!);
            }
            else{
              //removeUpvoteToNotification(postOwnerId!, postId!);
            }
          }
          else{
            const snackBar = SnackBar(content: Text('You need to sign in to upvote posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        //icon: Icon(Icons.arrow_upward, color: isUpvoted ? Colors.green : Colors.grey)// todo change
        icon: Icon(Icons.thumb_up, color: isUpvoted ? Colors.green : Colors.grey)// todo change
    );
  }

  /*
  addUpvoteToNotification(String ownerId, String postId) {
    /// Since we are going to be updating the same document referenced by the:
    /// 1. owner id
    /// 2. the post id
    /// this is going to be overwritten everytime a like is made to that post
    /// TODO: If we want to change it, it is easy; simply:
    /// change the .doc(postId).set({...}) to .add({...})
    bool isNotPostOwner = getCurrUid() != ownerId;
    if (isNotPostOwner) {
      notificationsCollection
          .doc(ownerId)
          .collection("feedItems")
          .add({
        "type": "like",
        "userId": widget.user.uid,
        "postId": postId,
        "timestamp": timestamp,
      });
    }
  }

  removeUpvoteToNotification(String ownerId, String postId) {
    bool isNotPostOwner = widget.user.uid != ownerId;
    if (isNotPostOwner) {
      notificationsCollection
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }
  */


  Widget _buildDownvoteButton(){
    String? postId = widget.snapshot?.data!.docs[widget.index].id;
    String? postOwnerId =  widget.snapshot?.data!.docs[widget.index].data()!['user_uid'];
    String? userId = getCurrUid();

    List? upvotesList = widget.snapshot?.data!.docs[widget.index].data()!['upvotes'];
    isUpvoted = upvotesList?.contains(userId) ?? false;

    List? downvotesList = widget.snapshot?.data!.docs[widget.index].data()!['downvotes'];
    isDownvoted = downvotesList?.contains(userId) ?? false;

    return IconButton(
        onPressed: () {
          if (widget.user.isAuthenticated) {
            isDownvoted = !isDownvoted;
            if (isDownvoted && isUpvoted) {
              isUpvoted = false;
              widget.user.modifyVote(postId, postOwnerId, 'upvotes', isUpvoted);
            }
            setState(() {});
            widget.user.modifyVote(postId, postOwnerId, 'downvotes', isDownvoted);
          }
          else{
            const snackBar = SnackBar(content: Text('You need to sign in to downvote posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        //icon: Icon(Icons.arrow_downward, color: isDownvoted ? Colors.green : Colors.grey)
        icon: Icon(Icons.thumb_down, color: isDownvoted ? Colors.green : Colors.grey)
    );
  }

  Widget _buildSaveButton(){
    return IconButton(
        onPressed: () {
          if (widget.user.isAuthenticated) {
            isSaved = !isSaved;
            setState(() {});
            if (!isSaved) {
              widget.user.modifySaved(
                  widget.data != null
                      ? widget.data!['uid']
                      : widget.snapshot?.data!.docs[widget.index].id,
                  true
              );
            } else {
              widget.user.modifySaved(
                  widget.data != null
                      ? widget.data!['uid']
                      : widget.snapshot?.data!.docs[widget.index].id,
                  false
              );
            }
          }
          else {
            const snackBar = SnackBar(content: Text('You need to sign in to save posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: Icon(Icons.bookmark, color: isSaved ? appTheme : Colors.grey)
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.user = Provider.of<AuthRepository>(context);

    if (widget.user.isAuthenticated) {
      /// Update isSaved, isUpvoted, isDownvoted
      var saved = widget.user.savedPosts;
      isSaved =
        saved == null
          ? false
          : saved.contains(
          widget.data != null
              ? widget.data!['uid']
              : widget.snapshot?.data!.docs[widget.index].id
      );

      var cat =
        widget.data != null
          ? widget.data!['category']
          : widget.snapshot?.data!.docs[widget.index].data()!['category'];
      if (widget.goalFiltered != null && widget.goalFiltered! && cat == 'Blog') {
        return Container();
      }

      if (widget.goalFiltered != null && widget.goalFiltered!) {
        var postGoals =
          widget.data != null
            ? widget.data!['goals']
            : widget.snapshot?.data!.docs[widget.index].data()!['goals'];
        if (cat == "Blog") {
          Container();
        }
        var userGoal = widget.user.userData.goal;
        if (!postGoals[userGoal]!) {
          return Container();
        }
      }
    }

    var tmp = (widget.data?['description']
        ?? widget.snapshot?.data!.docs[widget.index].data()!['description']) as String;

    return InkWell(
      onTap: () {
        var cat = widget.data?['category'] ?? widget.snapshot?.data!.docs[widget.index].data()!['category'];
        var args = widget.data ?? widget.snapshot?.data!.docs[widget.index].data()!;
        if (cat == 'Blog') {
          Navigator.pushNamed(context, viewBlogRoute, arguments: args);
        } else if (cat == 'Workout') {
          Navigator.pushNamed(context, viewWorkoutRoute, arguments: args);
        } else {
          Navigator.pushNamed(context, viewMealPlanRoute, arguments: args);
        }
      },
      child: Card(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// user pic + name + 3 dots
                StreamBuilder<Map<String, dynamic>?>(
                    stream: _postManager.getUserInfo(
                        widget.data?['user_uid']
                            ?? widget.snapshot?.data!.docs[widget.index].data()!['user_uid']
                    ).asStream(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting && userSnapshot.data == null) {
                        return const Center(child: LinearProgressIndicator());
                      }
                      if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.data == null) {
                        return const ListTile();
                      }
                      return ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        leading: GestureDetector(
                            onTap: () {
                              SearchArguments arg = SearchArguments(
                                  uid: widget.data?['user_uid']
                                      ?? widget.snapshot?.data!.docs[widget.index].data()!['user_uid'],
                                  isUser: true);
                              Navigator.pushNamed(context, '/profile', arguments: arg);
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: widget.userPicture != null
                                  ? widget.userPicture?.image
                                  : (widget.data?['picture'] ?? NetworkImage(userSnapshot.data!['picture']!)),
                            )
                        ),
                        title: RichText(
                          text: TextSpan(
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.category
                                      ?? (widget.data?['category']
                                          ?? widget.snapshot?.data!.docs[widget.index].data()!['category']
                                      ),
                                  style: TextStyle(color: Theme.of(context).appBarTheme.backgroundColor)
                              ),
                              const TextSpan(text: ' by '),
                              TextSpan(text: widget.data?['name'] ?? userSnapshot.data!['name']),
                            ],
                          ),
                        ),
                        subtitle: Text(
                            widget.date != null
                                ? timeago.format(widget.date!,
                                allowFromNow: true)
                                : timeago.format(
                                widget.data != null? (widget.data?['createdAt'].toDate()) : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'] != null
                                    ? widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate()
                                    : DateTime.now()),
                                allowFromNow: true),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey)
                        ),
                        trailing: widget.screen == 'timeline'
                            ? null
                            : PopupMenuButton(
                              icon: const Icon(Icons.more_horiz),
                              /*onSelected: (value) {
                                      PostManager().deletePost(widget
                                          .snapshot?.data!.docs[widget.index].id);
                                    },*/
                              onSelected: (value) async {
                                if (value == 1) {
                                  Widget cancel = TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel', style: TextStyle(color: appTheme))
                                  );
                                  Widget confirm = TextButton(
                                      onPressed: () {
                                        widget
                                            .user
                                            .modifySaved(widget.snapshot?.data!.docs[widget.index].id, true);
                                        PostManager().deletePost(widget.snapshot?.data!.docs[widget.index].id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Confirm', style: TextStyle(color: appTheme)));
                                  AlertDialog alert = AlertDialog(
                                    title: const Text('Are you sure?'),
                                    content: const Text('Posts are not retrievable after deletion.'),
                                    actions: [cancel, confirm],
                                  );
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return alert;
                                      });
                                }
                                else if (value==2) {
                                  var category= widget.snapshot?.data!.docs[widget.index].data()!['category']!;
                                  var args = widget.snapshot?.data!.docs[widget.index];
                                  if(category == "Blog") {
                                    Navigator.pushNamed(context, editBlogRoute, arguments: args);
                                  }
                                  else if (category == "Workout") {
                                    Navigator.pushNamed(context, editWorkoutRoute, arguments: args);
                                  }
                                  else{
                                    Navigator.pushNamed(context, editMealPlanRoute, arguments: args);
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(value: 2, child: Text('Edit post')),
                                const PopupMenuItem(value: 1, child: Text('Delete post')),
                              ],
                            ),
                      );
                    }),
                Text( widget.data?['title']
                    ?? widget.snapshot?.data!.docs[widget.index].data()!['title']!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                    widget.data != null
                        ? widget.data!['description']
                        .substring(0, min(500, tmp.length))
                        + (500 < tmp.length ? '...' : '')
                        : widget.snapshot?.data!.docs[widget.index].data()!['description']!
                        .substring(0, min(500, tmp.length))
                        + (500 < tmp.length ? '...' : ''),
                    textAlign: TextAlign.left,
                    maxLines: 7
                ),
                const SizedBox(height: 5),
                ((widget.data!= null && widget.data!['image_url'] != null)
                    || widget.snapshot?.data!.docs[widget.index].data()!['image_url'] != null)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.data != null
                            ? widget.data!['image_url']
                            : (widget.data?['image_url'] ?? widget.snapshot?.data!.docs[widget.index].data()!['image_url']!),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildUpvoteButton(),
                        Text(
                          (widget.data?['rating'] ?? widget.snapshot?.data.docs[widget.index].data()['rating']).toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.9),
                              fontWeight: FontWeight.bold),
                        ),
                        _buildDownvoteButton(),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          (widget.data?['commentsNum'] ??
                              widget.snapshot?.data.docs[widget.index]
                                  .data()['commentsNum'])
                              .toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.9),
                              fontWeight: FontWeight.bold),
                        ),
                        _buildCommentButton(),
                      ],
                    ),

                    _buildSaveButton(),
                  ],
                )
              ],
            ),
          )),
    );
  }
}