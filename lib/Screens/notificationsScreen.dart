/*import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width  = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: height * 0.01),
            const Flexible(
                child: Text(
                  'Notifications are coming soon',
                  style: TextStyle(fontSize: 20),
                )),
            Flexible(
                child: Image.asset(
                  'images/decorations/work-in-progress.png',
                  width: width * 0.3,
                  height: height * 0.3,
                ))
          ],
        ),
      )
    );
  }

}*/
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late AuthRepository user;

  /// Returns list of all notifications relevant to currUser
  Future<List<NotificationItem>> getNotificationsList() async {
    List<NotificationItem> feedItems = [];
    await notificationsCollection
        .doc(getCurrUid())
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        feedItems.add(NotificationItem.fromDocument(doc));
      });
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthRepository>(context);
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Notifications')),
      body: FutureBuilder(
        future: getNotificationsList(),
        builder: (context, AsyncSnapshot<List<NotificationItem>> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (snapshot.data!.isEmpty) {
            return emptyNote(
                'You don\'t have any notifications yet',
                MediaQuery.of(context).size.height,
                MediaQuery.of(context).size.width);
          }
          return ListView(children: snapshot.data as List<NotificationItem>);
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String userId;
  final String type;

  /// 'upvote', 'downvote', 'follow', 'comment'
  final String postId;
  final String commentData;
  final Timestamp timestamp;
  late bool? isUserRedirect;

  NotificationItem({
    super.key,
    required this.userId,
    required this.type,

    /// 'upvote', 'downvote', 'follow', 'comment'
    required this.postId,
    required this.commentData,
    required this.timestamp,
  });

  factory NotificationItem.fromDocument(DocumentSnapshot doc) {
    return NotificationItem(
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  String configureActivityItemText() {
    if (type == 'upvote') {
      isUserRedirect = false;
      return 'upvoted your post';
    } else if (type == 'downvote') {
      isUserRedirect = false;
      return 'downvoted your post';
    } else if (type == 'follow') {
      isUserRedirect = true;
      return "is following you";
    } else if (type == 'comment') {
      isUserRedirect = false;
      return 'replied: $commentData';
    } else {
      return "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    String activityItemText = configureActivityItemText();
    return FutureBuilder(
        future: Future.wait([
          PostManager().getUserPicAndName(userId)
          /*,PostManager().getPostPicture*/
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final userMap = snapshot.data![0];
            String userName = userMap['name'];
            String userPic = userMap['picture'];

            if (isUserRedirect!) {
              return InkWell(
                onTap: () {
                  SearchArguments arg =
                      SearchArguments(uid: userId, isUser: true);
                  Navigator.pushNamed(context, '/profile', arguments: arg);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Container(
                    color: Colors.white54,
                    child: ListTile(
                      title: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14.0, color: Colors.black),
                            children: [
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      SearchArguments arg = SearchArguments(
                                          uid: userId, isUser: true);
                                      Navigator.pushNamed(context, '/profile',
                                          arguments: arg);
                                    },
                                  text: userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appTheme)),
                              TextSpan(text: ' $activityItemText')
                            ]),
                      ),
                      leading: GestureDetector(
                          onTap: () {
                            SearchArguments arg =
                                SearchArguments(uid: userId, isUser: true);
                            Navigator.pushNamed(context, '/profile',
                                arguments: arg);
                          },
                          child: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(userPic))),
                      subtitle: Text(timeago.format(timestamp.toDate()),
                          overflow: TextOverflow.ellipsis),
                      //trailing: mediaPreview,
                    ),
                  ),
                ),
              );
            } else {
              return FutureBuilder(
                  future: Future.wait([
                    PostManager().getPostType(postId)
                    /*,PostManager().getPostPicture*/
                  ]),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot1) {
                    return InkWell(
                      onTap: () {
                        final postCat = snapshot1.data![0];
                        print('----------------------------------');
                        print(postCat);
                        print('----------------------------------');
                        var cat = postCat['category'];

                        if (postCat == 'Blog') {
                          Navigator.pushNamed(context, viewBlogRoute, );
                        } else if (postCat == 'Workout') {
                          Navigator.pushNamed(context, viewWorkoutRoute, );
                        } else {
                          Navigator.pushNamed(context, viewMealPlanRoute, );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Container(
                          color: Colors.white54,
                          child: ListTile(
                            title: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                  children: [
                                    TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            SearchArguments arg =
                                                SearchArguments(
                                                    uid: userId, isUser: true);
                                            Navigator.pushNamed(
                                                context, '/profile',
                                                arguments: arg);
                                          },
                                        text: userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: appTheme)),
                                    TextSpan(text: ' $activityItemText')
                                  ]),
                            ),
                            leading: GestureDetector(
                                onTap: () {
                                  SearchArguments arg = SearchArguments(
                                      uid: userId, isUser: true);
                                  Navigator.pushNamed(context, '/profile',
                                      arguments: arg);
                                },
                                child: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(userPic))),
                            subtitle: Text(timeago.format(timestamp.toDate()),
                                overflow: TextOverflow.ellipsis),
                            //trailing: mediaPreview,
                          ),
                        ),
                      ),
                    );
                  });
            }
          } else {
            return const CircularProgressIndicator(); //TODO: change
          }
        });
  }
}
