import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/post_template.dart';

class MyPost1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostTemplate(
      username: 'mclovin',
      profilePicture: 'images/decorations/mclovin.png',
      description: 'Jesus died for our sins, Harambe died for our memes. #rip #legend #wow',
      postPicture: 'images/posts/harambe.jpg',
    );
  }
}
