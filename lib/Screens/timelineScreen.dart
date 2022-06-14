import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

/*
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
        title: const Text('Only show posts that match my goal',
            style: TextStyle(color: appTheme)),
        value: widget.goalOrientation,
        activeColor: appTheme,
        onChanged: (value) => setState(() {
              widget.goalOrientation = value!;
            }));
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
                  style: TextStyle(
                      color: appTheme,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
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
*/
class TimelineScreen extends StatefulWidget {
  bool? isGoalOriented = false;
  String sorting = 'createdAt';

  TimelineScreen({Key? key, bool? oriented = false}) : super(key: key) {
    this.isGoalOriented = oriented ?? false;
  }

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  final PostManager _postManager = PostManager();

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

  Future openSortDialog(double height, double width) => showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStatee) => AlertDialog(
                insetPadding: EdgeInsets.only(left: width * 0.16, right: width * 0.16,top: height * 0.30, bottom: height * 0.315),
                title: const Center(child: Text('Sorting Options')),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                        title: const Text('Most Recent'),
                        value: 'createdAt',
                        groupValue: widget.sorting,
                        activeColor: appTheme,
                        onChanged: (value) => setStatee(() {
                          widget.sorting = value!;
                          Navigator.of(context).pop();
                          //userGoal = value!;
                        })),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 1,
                      indent: width * 0.05,
                      endIndent: width * 0.1,
                    ),
                    RadioListTile<String>(
                        title: const Text('Most Rating'),
                        value: 'rating',
                        groupValue: widget.sorting,
                        activeColor: appTheme,
                        onChanged: (value) => setStatee(() { //todo
                          widget.sorting = value!;
                          Navigator.of(context).pop();
                          //userGoal = value!;
                        })),
                    Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 1,
                      indent: width * 0.05,
                      endIndent: width * 0.1,
                    ),
                    RadioListTile<String>(
                        title: const Text('Most Comments'),
                        value: 'commentsNum',
                        groupValue: widget.sorting,
                        activeColor: appTheme,
                        onChanged: (value) => setStatee(() {
                          widget.sorting = value!;
                          Navigator.of(context).pop();
                          //userGoal = value!;
                        })),
                  ],
                ),

              ))
  );

  Future openFilterDialog() => showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStatee) => AlertDialog(
            title: const Center(child: Text('Filter Options'),),
            content: CheckboxListTile(
                title: const Text('Only show posts that match my goal',
                    style: TextStyle(color: appTheme)),
                value: widget.isGoalOriented,
                activeColor: appTheme,
                onChanged: (value) => setStatee(() {
                  widget.isGoalOriented = value!;
                })),
            actions: [
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setStatee(() => widget.isGoalOriented =
                          widget.isGoalOriented!);
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: appTheme,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      )
                    ]),
              )
            ],
          )));

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    widget.isGoalOriented ??= false;
    var user = Provider.of<AuthRepository>(context);
    //  FilterDialog filters =
    //       FilterDialog(goalOrientation: widget.isGoalOriented ?? false);
    return Scaffold(
        appBar: AppBar(
            title: const Text('YourFitnessGuide'),
            centerTitle: false,
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child:
                      IconButton(
                          onPressed: () async {
                            await openFilterDialog();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.filter_alt,
                            color: Colors.white,
                          ))
                    ),
              (user.isAuthenticated
                  ? Padding(
                      padding: const EdgeInsets.only(right: 1.0),
                      child:
                          IconButton(
                              onPressed: () async {
                                await openSortDialog(height, width);
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.sort,
                                color: Colors.white,
                              ))
                        )
                  : const Padding(padding: EdgeInsets.all(0))),
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
            stream: _postManager.getAllPosts(widget.sorting),
            builder: (context, snapshot) {
              return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount:
                        snapshot.data == null ? 0 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator.adaptive());
                      }
                      if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
                        return const Center(child: Text('No data available'));
                      }
                      return post(
                        index: index,
                        snapshot: snapshot,
                        screen: "timeline",
                        goalFiltered: widget.isGoalOriented ?? false,
                      );
                    },
                  ));
            }));
  }
}
