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
                          const snackBar = SnackBar(content: Text('Filtering options coming soon'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        icon: const Icon(
                          Icons.filter_alt,
                          color: Colors.white,
                        ))
                  ],
                )),
          ]
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        openCloseDial: isDialOpen,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, //todo change
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
        builder: (context, snapshot) { return RefreshIndicator( onRefresh: () async{
          setState(() {

          });
          //TODO: Saleh\Mahmoud complete refresh functionality
          print('Refreshing');
          return null; },
        child:
          ListView.builder(
            //separatorBuilder: (context, index) => const Divider(),
            itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
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
              return post(snapshot: snapshot, index: index);
            },
          ));
          }
      )
    );
  }
}
