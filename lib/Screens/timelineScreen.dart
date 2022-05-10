import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
          Card(
            elevation: 5,
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                        Image.asset('images/decorations/mclovin.png').image //picture
                    ),
                    title: Text('McLovin',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                        onPressed: null,//todo
                        icon: Icon(
                          Icons.more_horiz,
                          color:
                          Theme.of(context).iconTheme.color,
                        )),
                    ),
                    const Text( 'Jesus died for our sins, Harambe died for our memes. #rip #legend #wow',
                        textAlign: TextAlign.left),

                      Column(
                        crossAxisAlignment:  CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'images/posts/harambe.jpg',
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                          Icons.arrow_upward,
                                          color: Colors.grey
                                      )
                                  ),
                                  IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                          Icons.arrow_downward,//.comment_lines,
                                          color: Colors.grey
                                      )
                                  )
                                ],
                              ),
                              const IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.chat_bubble,
                                  color: Colors.grey
                                )
                              ),
                              const IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.bookmark,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                        ],
                      ),
                ]
              )
            )
          )
        ],
      ),
    );
  }
}
