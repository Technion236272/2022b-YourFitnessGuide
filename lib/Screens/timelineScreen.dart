import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class filterDialog extends StatefulWidget {
  bool goalOrientation;
  filterDialog({Key? key, required this.goalOrientation}) : super(key: key);
  get goalOriented => goalOrientation;

  @override
  State<filterDialog> createState() => _filterDialogState();
}

class _filterDialogState extends State<filterDialog> {
  @override
  Widget build(BuildContext context) {
    Widget cancel = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Cancel',
          style: TextStyle(color: appTheme),
        ));
    Widget tmp = CheckboxListTile(
        title: Text('Show posts that match my goal only', style: TextStyle(color: appTheme),),
        value: widget.goalOrientation,
        //groupValue: userGoal,
        activeColor: appTheme,
        onChanged: (value) => setState(() {
          widget.goalOrientation = value!;
        }));
    Widget confirm = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Confirm',
            style: TextStyle(color: appTheme)));
    AlertDialog alert = AlertDialog(
      title: const Text('Filters'),
      content: tmp,
      actions: [cancel, confirm],
    );
    return alert;
  }
}


class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  final PostManager _postManager = PostManager();
  bool isGoalOriented = false;

  SpeedDialChild _buildDialOption(String name, String Route) {
    return SpeedDialChild(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: name,
        labelBackgroundColor: appTheme,
        backgroundColor: appTheme,
        labelStyle: TextStyle(color: Colors.white),
        onTap: () {
          isDialOpen.value = false;
          Navigator.pushNamed(context, Route);
        });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthRepository>(context);
    filterDialog filters = filterDialog(goalOrientation: isGoalOriented);

    return Scaffold(
        appBar: AppBar(
            title: const Text('YourFitnessGuide'),
            centerTitle: false,
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext) {
                                  return filters;
                                });
                            print(filters.goalOriented);
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
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          //todo change
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: true,
          visible: user.isAuthenticated,
          children: [
            _buildDialOption('Blog Post', blogPostRoute),
            _buildDialOption('Meals Plan', mealPlanRoute),
            _buildDialOption('Workout Routine', workoutPostRoute),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>?>>(
            stream: _postManager.getAllPosts(),
            builder: (context, snapshot) {
              return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
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
                      return post(
                        index: index,
                        snapshot: snapshot,
                        screen: "timeline",
                      );
                    },
                  ));
            }));
  }
}
