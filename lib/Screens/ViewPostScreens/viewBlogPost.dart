import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewBlogPostScreen extends StatefulWidget {
  late var post_data;

  ViewBlogPostScreen({Key? key, this.post_data}) : super(key: key);

  @override
  State<ViewBlogPostScreen> createState() => _ViewBlogPostScreenState();
}

class _ViewBlogPostScreenState extends State<ViewBlogPostScreen> {
  TextEditingController postNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  get post_data => widget.post_data;
  final PostManager _postManager = PostManager();
  late var user_data;

  Widget _buildPostName(double height) {
    final iconSize = height * 0.050;
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/post_name.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Title",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.name,
                controller: postNameController,
                textAlign: TextAlign.left,
                readOnly: true,
                decoration: InputDecoration(border: InputBorder.none),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(double height) {
    final iconSize = height * 0.050;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/icons/description.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /* Text(
                "Description",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),

              */
              TextField(
                minLines: 1,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                textAlign: TextAlign.left,
                readOnly: true,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 5),
                    label: false
                        ? Center(
                            child: Text("Description"),
                          )
                        : Text("Description"),
                    hintStyle:
                        TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                    labelStyle: TextStyle(
                      color: appTheme,
                      fontSize: 27,
                      fontWeight: FontWeight.normal,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: InputBorder.none),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    postNameController.text = post_data["title"];
    descriptionController.text = post_data["description"];
    user_data = _postManager.getUserInfo(post_data["user_uid"]).asStream();

    return Scaffold(
      appBar: AppBar(
          title: Text('${post_data["title"]}'),
          backgroundColor: appTheme,
          centerTitle: false),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(height: height * 0.012),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 40, 0),
          child: StreamBuilder<Map<String, dynamic>?>(
              stream: user_data,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting &&
                    userSnapshot.data == null) {
                  return const Center(child: LinearProgressIndicator());
                }
                if (userSnapshot.connectionState == ConnectionState.done &&
                    userSnapshot.data == null) {
                  return const ListTile();
                }
                return ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        NetworkImage(userSnapshot.data!['picture']!),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: post_data['category'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor)),
                        const TextSpan(text: ' by '),
                        TextSpan(text: userSnapshot.data!['name']),
                      ],
                    ),
                  ),
                  subtitle: Text(
                      timeago.format(post_data['createdAt'].toDate(),
                          allowFromNow: true),
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey)),
                );
              }),
        ),
        Divider(
          height: height * 0.00001,
          thickness: 1,
          color: Colors.black45,
        ),
        (post_data!['image_url'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post_data!['image_url']!,
                  height: 300,
                  width: MediaQuery.of(context).size.width * 0.9,
                  fit: BoxFit.cover,
                ),
              )
            : const Padding(padding: EdgeInsets.all(0))),
        Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 40, 10),
            child: _buildDescription(height)),
      ]),
      resizeToAvoidBottomInset: false,
    );
  }
}
