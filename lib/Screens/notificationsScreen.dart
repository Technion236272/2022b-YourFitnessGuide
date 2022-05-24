import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notifications'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: height * 0.01,
            ),
            Flexible(
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

}