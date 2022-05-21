import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  final PostManager _postManager = PostManager();


  SpeedDialChild _buildDialOption(String name, String Route){
    return SpeedDialChild(
        child: const Icon(Icons.add),
        label: name,
        onTap: () {
          isDialOpen.value = false;
          Navigator.pushNamed(context, Route);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthRepository>(context);

    return Scaffold(
        appBar: AppBar(
            title: const Text('YourFitnessGuide'),
            centerTitle: true,
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            const snackBar = SnackBar(
                                content: Text('Filtering options coming soon'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          icon: const Icon(
                            Icons.filter_alt,
                            color: Colors.white,
                          ))
                    ],
                  )),
            ]),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isDialOpen,
          backgroundColor:
              Theme.of(context).appBarTheme.backgroundColor, //todo change
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: true,
          visible: user.isAuthenticated,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.add),
                label: 'Blog Post',
                onTap: () {
                  isDialOpen.value = false;
                  Navigator.pushNamed(context, blogPostRoute);
                }),
            SpeedDialChild(
                child: const Icon(Icons.add),
                label: 'Meals Plan',
                onTap: () {
                  isDialOpen.value = false;
                  Navigator.pushNamed(context, mealPlanRoute);
                }),
            SpeedDialChild(
                child: const Icon(Icons.add),
                label: 'Workout Routine',
                onTap: () {
                  isDialOpen.value = false;
                  Navigator.pushNamed(context, workoutPostRoute);
                }),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>?>>(
            stream: _postManager.getAllPosts(),
            builder: (context, snapshot) {
              return RefreshIndicator(
                  onRefresh: () async {
                    print('Refreshing');
                    return null;
                  },
                  child: ListView.builder(
                    //separatorBuilder: (context, index) => const Divider(),
                    itemCount:
                        snapshot.data == null ? 0 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          snapshot.data == null) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }

                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data == null) {
                        return const Center(child: Text('No data available'));
                      }

                      return GestureDetector(
                        onTap: () => {
                          //Navigator.pushNamed(context, viewBlogRoute)

                          // print(snapshot.data!.docs[index].data()!)
                          //print(snapshot.data!.docs[index].data()!)

                          if (snapshot.data!.docs[index].data()!['category'] ==
                              'Blog')
                            {
                              Navigator.pushNamed(context, viewBlogRoute,
                                  arguments: snapshot.data!.docs[index].data()!)
                            }
                          else if (snapshot.data!.docs[index]
                                  .data()!['category'] ==
                              'Workout')
                            {
                              Navigator.pushNamed(context, viewWorkoutRoute,
                                  arguments: snapshot.data!.docs[index].data()!)
                            }
                          else if (snapshot.data!.docs[index]
                                  .data()!['category'] ==
                              'Meal Plan')
                            {
                              Navigator.pushNamed(context, viewMealPlanRoute,
                                  arguments: snapshot.data!.docs[index].data()!)
                            }

                        },
                        child: Card(
                          elevation: 5,
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// user pic + name + 3 dots
                                StreamBuilder<Map<String, dynamic>?>(
                                    stream: _postManager
                                        .getUserInfo(snapshot.data!.docs[index]
                                            .data()!['user_uid'])
                                        .asStream(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                              ConnectionState.waiting &&
                                          userSnapshot.data == null) {
                                        return const Center(
                                            child: LinearProgressIndicator());
                                      }
                                      if (userSnapshot.connectionState ==
                                              ConnectionState.done &&
                                          userSnapshot.data == null) {
                                        return const ListTile();
                                      }
                                      return ListTile(
                                        contentPadding: const EdgeInsets.all(0),
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                              userSnapshot.data!['picture']!),
                                        ),
                                        title: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(fontSize: 16),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: snapshot
                                                      .data!.docs[index]
                                                      .data()!['category'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .appBarTheme
                                                          .backgroundColor)),
                                              const TextSpan(text: ' by '),
                                              TextSpan(
                                                  text: userSnapshot
                                                      .data!['name']),
                                            ],
                                          ),
                                        ),
                                        subtitle: Text(
                                            timeago.format(
                                                snapshot.data!.docs[index]
                                                    .data()!['createdAt']
                                                    .toDate(),
                                                allowFromNow: true),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey)),
                                        trailing: IconButton(
                                            onPressed: null,
                                            icon: Icon(
                                              Icons.more_horiz,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            )),
                                      );
                                    }),
                                Text(
                                  snapshot.data!.docs[index].data()!['title']!,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  snapshot.data!.docs[index]
                                      .data()!['description']!,
                                  textAlign: TextAlign.left,
                                ),
                                (snapshot.data!.docs[index]
                                            .data()!['image_url'] !=
                                        null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          snapshot.data!.docs[index]
                                              .data()!['image_url']!,
                                          height: 200,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.all(0))),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              const _snackBar = SnackBar(
                                                  content: Text(
                                                      'Not implemented yet'));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(_snackBar);
                                            },
                                            icon: const Icon(Icons.arrow_upward,
                                                color: Colors.grey)),
                                        IconButton(
                                            onPressed: () {
                                              const _snackBar = SnackBar(
                                                  content: Text(
                                                      'Not implemented yet'));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(_snackBar);
                                            },
                                            icon: const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.grey))
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          const _snackBar = SnackBar(
                                              content:
                                                  Text('Not implemented yet'));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(_snackBar);
                                        },
                                        icon: const Icon(Icons.chat_bubble,
                                            color: Colors.grey)),
                                    IconButton(
                                        onPressed: () {
                                          const _snackBar = SnackBar(
                                              content:
                                                  Text('Not implemented yet'));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(_snackBar);
                                        },
                                        icon: const Icon(Icons.bookmark,
                                            color: Colors.grey))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ));
            })
        );
  }
}
