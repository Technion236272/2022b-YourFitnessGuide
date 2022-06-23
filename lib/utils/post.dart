import 'dart:math';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/managers/notifications_manager.dart';


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
  bool? isBlogSelected = false;
  bool? isWorkoutSelected = false;
  bool? isMealPlanSelected= false;
  bool? isPostsbyfollowingSelected=false;
  String? timeRange='no time selected';
  int? minRating=-100000000;

  Post({Key? key,
    this.index,
    this.snapshot,
    required this.screen,
    this.goalFiltered,this.isBlogSelected,this.isWorkoutSelected,this.isMealPlanSelected,
    this.timeRange,this.minRating,this.isPostsbyfollowingSelected, this.uid, this.data})
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

          return const ListTile();
        });
  }

  @override
  State<Post> createState() => _PostState();


}

class _PostState extends State<Post> {
  bool isUpvoted = false;
  bool isDownvoted = false;
  bool isSaved = false;
  final _postManager = PostManager();

  Widget _buildCommentButton() {
    return IconButton(
        onPressed: () {
          String postId = widget.data != null
              ? widget.data!['uid']
              : widget.snapshot?.data!.docs[widget.index].id;
          Navigator.pushNamed(context, commentsRoute, arguments: {
            'postId': postId,
          });
        },
        icon: const Icon(Icons.chat_bubble, color: Colors.grey)
    );
  }

  Widget _buildUpvoteButton(){
    String? postId =  widget.data != null
        ? widget.data!['uid']
        : widget.snapshot?.data!.docs[widget.index].id;
    String? postOwnerId =  widget.data != null
        ? widget.data!['user_uid']
        : widget.snapshot?.data!.docs[widget.index].data()!['user_uid'];

    List? upvotesList =  widget.data != null
        ? widget.data!['upvotes']
        : widget.snapshot?.data!.docs[widget.index].data()!['upvotes'];
    isUpvoted = upvotesList?.contains(getCurrUid()) ?? false;

    List? downvotesList =  widget.data != null
        ? widget.data!['downvotes']
        : widget.snapshot?.data!.docs[widget.index].data()!['downvotes'];
    isDownvoted = downvotesList?.contains(getCurrUid()) ?? false;
    return IconButton(
        onPressed: () {
          if (widget.user.isAuthenticated) {
            isUpvoted = !isUpvoted;
            if (isUpvoted && isDownvoted) {
              isDownvoted = false;
              NotificationsManager().removeNotification(postOwnerId!, postId!, 'downvote');
              widget.user.modifyVote(postId, postOwnerId, 'downvotes', isDownvoted);
            }
            setState(() {});
            widget.user.modifyVote(postId, postOwnerId, 'upvotes', isUpvoted);

            /// Notification
            if(isUpvoted) {
              NotificationsManager().addNotification(postId!, 'upvote', '');
            }
            else{
              NotificationsManager().removeNotification(postOwnerId!, postId!, 'downvote');
            }
          }
          else{
            const snackBar = SnackBar(content: Text('You need to sign in to upvote posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: Icon(Icons.thumb_up, color: isUpvoted ? appTheme : Colors.grey)
    );
  }

  Widget _buildDownvoteButton(){
    String? postId =  widget.data != null
        ? widget.data!['uid']
        : widget.snapshot?.data!.docs[widget.index].id;
    String? postOwnerId =  widget.data != null
        ? widget.data!['user_uid']
        : widget.snapshot?.data!.docs[widget.index].data()!['user_uid'];

    List? upvotesList =  widget.data != null
        ? widget.data!['upvotes']
        : widget.snapshot?.data!.docs[widget.index].data()!['upvotes'];
    isUpvoted = upvotesList?.contains(getCurrUid()) ?? false;

    List? downvotesList =  widget.data != null
        ? widget.data!['downvotes']
        : widget.snapshot?.data!.docs[widget.index].data()!['downvotes'];
    isDownvoted = downvotesList?.contains(getCurrUid()) ?? false;

    return IconButton(
        onPressed: () {
          if (widget.user.isAuthenticated) {
            isDownvoted = !isDownvoted;
            if (isDownvoted && isUpvoted) {
              isUpvoted = false;
              widget.user.modifyVote(postId, postOwnerId, 'upvotes', isUpvoted);
              NotificationsManager().removeNotification(postOwnerId!, postId!, 'upvote');
            }
            setState(() {});
            widget.user.modifyVote(postId, postOwnerId, 'downvotes', isDownvoted);

            /// Notification
            if(isDownvoted) {
              NotificationsManager().addNotification(postId!, 'downvote', '');
            }
            else{
              NotificationsManager().removeNotification(postOwnerId!, postId!, 'downvote');
            }
          }
          else{
            const snackBar = SnackBar(content: Text('You need to sign in to downvote posts'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: Icon(Icons.thumb_down, color: isDownvoted ? appTheme : Colors.grey)
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
  int _filterPostType(BuildContext context)
  {
    var cat =
    widget.data != null
        ? widget.data!['category']
        : widget.snapshot?.data!.docs[widget.index].data()!['category'];

    if( widget.isBlogSelected==true && widget.isWorkoutSelected==false
        && widget.isMealPlanSelected==false
        && (cat=='Workout' || cat=='Meal Plan')){
      return 1;
    }
    if( widget.isBlogSelected==false && widget.isWorkoutSelected==false
        && widget.isMealPlanSelected==true && (cat=='Blog'|| cat=='Workout' )
    )
    {
      return 1;
    }
    if( widget.isBlogSelected==false && widget.isWorkoutSelected==true
        && widget.isMealPlanSelected==false && (cat=='Blog'|| cat=='Meal Plan' )
    )
    {
      return 1;
    }
    if( widget.isBlogSelected==true && widget.isWorkoutSelected==true
        && widget.isMealPlanSelected==false
        && ( cat=='Meal Plan')){
      return 1;
    }
    if( widget.isBlogSelected==true && widget.isWorkoutSelected==false
        && widget.isMealPlanSelected==true
        && ( cat=='Workout')){
      return 1;
    }

    if( widget.isBlogSelected==false && widget.isWorkoutSelected==true
        && widget.isMealPlanSelected==true && (cat=="Blog")
    )
    {
      return 1;
    }


    return 0;
  }
  int _filterTimeRange(BuildContext context,String? timerange)
  {
    if(timerange==null)
      return 0;
    if(timerange=='a day ago') {
      DateTime time = DateTime.now().subtract(Duration(days: 1));
      DateTime postCreationTime =
      widget.data != null ? (widget.data?['createdAt'].toDate())
          : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate());
      //print(postCreationTime.isAfter(time));
      if (postCreationTime.isBefore(time))
        return 1;
    }
    if(timerange=='5 days ago') {
      DateTime time = DateTime.now().subtract(Duration(days: 5));
      DateTime postCreationTime =
      widget.data != null ? (widget.data?['createdAt'].toDate())
          : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate());
      //print(postCreationTime.isAfter(time));
      if (postCreationTime.isBefore(time))
        return 1;
    }
    if(timerange=='10 days ago') {
      DateTime time = DateTime.now().subtract(Duration(days: 10));
      DateTime postCreationTime =
      widget.data != null ? (widget.data?['createdAt'].toDate())
          : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate());
      //print(postCreationTime.isAfter(time));
      if (postCreationTime.isBefore(time))
        return 1;
    }
    if(timerange=='15 days ago') {
      DateTime time = DateTime.now().subtract(Duration(days: 15));
      DateTime postCreationTime =
      widget.data != null ? (widget.data?['createdAt'].toDate())
          : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate());
      //print(postCreationTime.isAfter(time));
      if (postCreationTime.isBefore(time))
        return 1;
    }
    if(timerange=='a month ago') {
      DateTime time = DateTime.now().subtract(Duration(days: 30));
      DateTime postCreationTime =
      widget.data != null ? (widget.data?['createdAt'].toDate())
          : (widget.snapshot?.data!.docs[widget.index].data()!['createdAt'].toDate());
      //print(postCreationTime.isAfter(time));
      if (postCreationTime.isBefore(time))
        return 1;
    }
    return 0;
  }
  int _filterMinRating(BuildContext context,int minRating)
  {
    int postRating=widget.data != null ? (widget.data?['rating'])
        : (widget.snapshot?.data!.docs[widget.index].data()!['rating']);
    //print(postRating);
    //print(minRating);
    if(postRating <minRating)
      return 1;

    return 0;
  }
  int _filterImFollowing(BuildContext context)
  {

    List? imFollowing=widget.user.userData.imFollowing;
    String? postuserid=widget.data != null
        ? widget.data!['user_uid']
        : widget.snapshot?.data!.docs[widget.index].data()!['user_uid'];

    if(imFollowing!.contains(postuserid)==false) {
      return 1;
    }
    //print(imFollowing);
    return 0;
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
      if(_filterPostType(context)==1)
        return Container();
      if(_filterTimeRange(context,widget.timeRange)==1)
        return Container();
      if(_filterMinRating(context,widget.minRating??-100000000)==1)
        return Container();
      if(widget.isPostsbyfollowingSelected==true &&_filterImFollowing(context)==1)
        return Container();

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
        var args = Map<String, dynamic>.from(widget.data ?? widget.snapshot?.data!.docs[widget.index].data()!);
        args.addAll({'uid' : widget.snapshot?.data!.docs[widget.index].id ?? widget.data!['uid'], 'isSaved': isSaved, });
        print(args);
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
                        trailing: widget.screen == 'timeline' || widget.screen=="Search"
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
                                  var post_id     = widget.snapshot?.data!.docs[widget.index].id;
                                  var title       = widget.snapshot?.data!.docs[widget.index].data()!['title']!;
                                  var description = widget.snapshot?.data!.docs[widget.index].data()!['description']!;
                                  var image_url   = widget.snapshot?.data!.docs[widget.index].data()!['image_url'];
                                  var goals       = widget.snapshot?.data!.docs[widget.index].data()!['goals'];
                                  var meals_name  = widget.snapshot?.data!.docs[widget.index].data()!['meals_name'];
                                  var meals_contents    = widget.snapshot?.data!.docs[widget.index].data()!['meals_contents'];
                                  var meals_ingredients = widget.snapshot?.data!.docs[widget.index].data()!['meals_ingredients'];
                                  var exercises   = widget.snapshot?.data!.docs[widget.index].data()!['exercises'];

                                  var args = {
                                    'post_id': post_id,
                                    'title': title,
                                    'description': description,
                                    'image_url': image_url,
                                    'goals': goals,
                                    'meals_contents': meals_contents,
                                    'meals_name': meals_name,
                                    'meals_ingredients': meals_ingredients,
                                    'exercises': exercises
                                  };
                                  var category = widget.snapshot?.data!.docs[widget.index].data()!['category']!;
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
                Text(
                  widget.data?['title'] ?? widget.snapshot?.data!.docs[widget.index].data()!['title']!,
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

                Visibility(
                  visible:  widget.screen != 'Search',
                  child: Row(
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
                  ),
                )
              ],
            ),
          )),
    );
  }
}
