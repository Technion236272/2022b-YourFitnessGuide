import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class FilterDialog extends StatefulWidget {
  bool goalOrientation;
  FilterDialog({Key? key, required this.goalOrientation}) : super(key: key);
  get goalOriented => goalOrientation;


  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {

  @override
  Widget build(BuildContext context) {
    Widget filter1 = CheckboxListTile(
        title: const Text('Only show posts that match my goal', style: TextStyle(color: appTheme)),
        value: widget.goalOrientation,
        activeColor: appTheme,
        onChanged: (value) => setState((){
            widget.goalOrientation = value!;
          })
    );
    Widget okButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK',
                textAlign: TextAlign.right,
                style: TextStyle(color: appTheme, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            )
          ]),
    );
    AlertDialog alert = AlertDialog(
      title: const Text('Filters'),
      content: filter1,
      actions: [okButton],
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

  SpeedDialChild _buildDialOption(String name, String route) {
    return SpeedDialChild(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: name,
        labelBackgroundColor: appTheme,
        backgroundColor: appTheme,
        labelStyle: const TextStyle(color: Colors.white),
        onTap: () {
          isDialOpen.value = false;
          Navigator.pushNamed(context, route);
        });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthRepository>(context);
    FilterDialog filters = FilterDialog(goalOrientation: isGoalOriented);
    return Scaffold(
        appBar: AppBar(
            title: const Text('YourFitnessGuide'),
            centerTitle: false,
            actions: [
              user.isAuthenticated
                ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) {
                                  return filters;
                                });
                          },
                          icon: const Icon(
                            Icons.filter_alt,
                            color: Colors.white,
                          )
                      )
                    ],
                  )
                )
              : const Padding(padding: EdgeInsets.all(0)),
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
                    itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator.adaptive());
                      }
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data == null) {
                        return const Center(child: Text('No data available'));
                      }
                      return post(index: index, snapshot: snapshot, screen: "timeline");
                    },
                  ));
            }));
  }
}
