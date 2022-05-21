import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';

class BlogPostScreen extends StatefulWidget {
  const BlogPostScreen({Key? key}) : super(key: key);

  @override
  State<BlogPostScreen> createState() => _BlogPostScreenState();
}

class _BlogPostScreenState extends State<BlogPostScreen> {
  TextEditingController postNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final PostManager _postManager = PostManager();
  bool _isLoading = false;
  File? _postImageFile = null;
  var color = appTheme;
  String photo = "attach a photo";

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
              TextField(
                keyboardType: TextInputType.name,
                controller: postNameController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: Text("Title"),
                  hintStyle: TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 27,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
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
          flex: 1,
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
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: Text("Description"),
                  hintStyle: TextStyle(height: 1, fontSize: 16, color: Colors.grey),
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 27,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future pickImage() async {
    try {
      final selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage == null) {
        const snackBar = SnackBar(content: Text('No image was selected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _postImageFile = null;
        return;
      }
      setState(() {
        _postImageFile = File(selectedImage.path);
      });
    } on PlatformException catch (_) {
      const snackBar = SnackBar(
          content: Text(
              'You need to grant permission if you want to select a photo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return Scaffold(
      appBar: AppBar(
          title: const Text('New Blog'),
          backgroundColor: appTheme,
          centerTitle: false,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : IconButton(
                            onPressed: () async {
                              final String title = postNameController.text;
                              final String description =
                                  descriptionController.text;
                              if (title == "" || description == "") {
                                const snackBar = SnackBar(
                                    content: Text(
                                        'You must enter title and description'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });
                                bool isSubmitted =
                                    await _postManager.submitBlog(
                                        title: title,
                                        description: description,
                                        postImage: _postImageFile);
                                setState(() {
                                  _isLoading = false;
                                });

                                if (isSubmitted) {
                                  const snackBar = SnackBar(
                                      content:
                                          Text('Blog posted successfully'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);

                                  Navigator.pop(context);
                                } else {
                                  const snackBar = SnackBar(
                                      content: Text(
                                          'There was a problem logging you in'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              }
                            },
                            icon: const Icon(Icons.check_sharp,
                                color: Colors.white)),
                  ],
                )),
          ]),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            SizedBox(height: height * 0.012),
            Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
                child: _buildPostName(height)),
            Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 40, 10),
                child: _buildDescription(height)),
            SizedBox(
              height: height * 0.02,
            ),
                (_postImageFile!=
                    null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _postImageFile!,
                    height: 300,
                    width:
                    MediaQuery.of(context).size.width*0.9,
                    fit: BoxFit.cover,
                  ),
                )  : const Padding(
                    padding: EdgeInsets.all(0))),
                const SizedBox(
                  height: 4,
                ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 40, 10),
              width: 205,
              height: 80.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
                  primary: color, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () async {
                  if (_postImageFile == null) {
                    await pickImage();
                    if(_postImageFile!=null) {
                      color = Colors.red;
                      photo = "detach the photo";
                    }
                  }
                  else {
                    _postImageFile = null;
                    color = appTheme;
                    photo = "attach a photo";
                  }
                  setState(() {
                    build(context);
                  });
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    const Icon(Icons.add_photo_alternate, color: Colors.white),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      photo,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),




          ])),

      resizeToAvoidBottomInset: false,
    );
  }
}
