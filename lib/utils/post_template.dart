import 'package:flutter/material.dart';

class PostTemplate extends StatelessWidget {


  final String username;
  final String profilePicture;
  final String description;
  final String postPicture;
  int likes;
  int comments;
  //final String saves;

  PostTemplate({
    required this.username,
    required this.profilePicture,
    required this.description,
    required this.postPicture,
    this.likes = 0,
    this.comments = 0,
    //required this.saves,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
          elevation: 5,
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: Image.asset(profilePicture).image //picture
                      ),
                      title: Text(username,
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
                    Text(description,
                        textAlign: TextAlign.left),

                    Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            postPicture,
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
        );
  }
}
