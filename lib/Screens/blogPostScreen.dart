
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class BlogPostScreen extends StatefulWidget {
  const BlogPostScreen({Key? key}) : super(key: key);

  @override
  State<BlogPostScreen> createState() => _BlogPostScreenState();
}

class _BlogPostScreenState extends State<BlogPostScreen> {
  final appTheme = const Color(0xff4CC47C);
  TextEditingController postNameController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
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
          flex:8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Post name",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                 // fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.name,
                controller: postNameController,
                textAlign: TextAlign.left ,
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
      mainAxisAlignment:MainAxisAlignment.start ,
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
          flex:8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Description",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                minLines: 1,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                controller: DescriptionController,
                textAlign: TextAlign.left ,
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
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Create a blog post',
          ),
          backgroundColor: appTheme,
          centerTitle: true,
        ),
        body: Center (

           child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
        SizedBox(
        height: height * 0.012,
        ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
            child: _buildPostName(height) ,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
            child: _buildDescription(height) ,
          ),

            Expanded(
              flex:8,
                child :Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child:Text('ATTACH PHOTO',
                            style: TextStyle(
                              color: appTheme,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('OK',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: appTheme,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('CANCEL',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: appTheme,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      )
                    ])
          ,
            ),
        ])

        ),
      resizeToAvoidBottomInset: false,
        );
  }
}
