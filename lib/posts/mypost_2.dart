import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/post_template.dart';

class MyPost2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PostTemplate(
      username: 'elonmusk',
      profilePicture: 'images/decorations/mclovin.png',
      description: 'these hoes aint loyal #depression #memesforlyfe',
      postPicture: 'images/posts/harambe.jpg',
    );
  }
}