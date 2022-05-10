import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:yourfitnessguide/posts/mypost_1.dart';
import 'package:yourfitnessguide/posts/mypost_2.dart';
import 'package:yourfitnessguide/posts/mypost_3.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _controller = PageController(initialPage: 0);
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'YourFitnessGuide',
        ),
        centerTitle: true,
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
        children: [
          SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Blog Post',
              onTap: (){
              }
          ),
          SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Meals Plan',
              onTap: (){
              }
          ),
          SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Workout Routine',
              onTap: (){
              }
          ),
        ],
      ),

      body: ListView(
        controller: _controller,
        scrollDirection: Axis.vertical,
        children: [
          MyPost1(),
          MyPost2(),
          MyPost3(),
        ],
      ),
    );
  }
}
