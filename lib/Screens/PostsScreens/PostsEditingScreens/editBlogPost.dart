import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:yourfitnessguide/services/image_crop.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class EditBlogPost extends StatefulWidget {
  late var post_data;

  EditBlogPost({Key? key, this.post_data}) : super(key: key);

  @override
  State<EditBlogPost> createState() => _EditBlogPostState();
}

class _EditBlogPostState extends State<EditBlogPost> {
  TextEditingController postNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final PostManager _postManager = PostManager();
  bool _isLoading = false;
  File? _postImageFile;
  var color = appTheme;
  String photoText = "Add Image";

  get post_data => widget.post_data;
  int firsttime = 0;

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
                maxLength: 30,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: Text("Title"),
                  hintStyle:
                      TextStyle(height: 1, fontSize: 16, color: Colors.grey),
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
                maxLines: 40,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 5),
                  label: Text("Description"),
                  hintStyle:
                      TextStyle(height: 1, fontSize: 16, color: Colors.grey),
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

      final croppedFile = await myImageCropper(selectedImage.path);

      setState(() {
        _postImageFile = File(croppedFile!.path); //File(selectedImage.path);
      });
    } on PlatformException catch (_) {
      const snackBar = SnackBar(
          content: Text(
              'You need to grant permission if you want to select a photo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

/*
  Future _fileFromImageUrl() async {
    if (post_data.data()!['image_url'] != null) {
      final response = await http.get(
          Uri.parse(post_data.data()!['image_url']!));

      final documentDirectory = await getApplicationDocumentsDirectory();

      final file = File(p.join(documentDirectory.path, 'image.png'));
      _postImageFile = file;
      color=Colors.red;
      photoText = "Remove Image";
      if (!mounted) return;
      setState(() {
        build(context);
      });
    }
  }

 */
  Future _fileFromImageUrl() async {
    if (post_data.data()!['image_url'] != null) {
      var rng = new Random();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file =
          new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
      http.Response response =
          await http.get(Uri.parse(post_data.data()!['image_url']!));
      await file.writeAsBytes(response.bodyBytes);
      _postImageFile = file;
      color = Colors.red;
      photoText = "Remove Image";
      if (!mounted) return;
      setState(() {
        build(context);
      });
    }
  }

  @override
  initState() {
    super.initState();
    postNameController.text = post_data.data()!['title']!;
    descriptionController.text = post_data.data()!['description']!;
    if (firsttime == 0) {
      _fileFromImageUrl();
      firsttime++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    var timestamp = post_data.data()!['createdAt']!;

    //print(_postImageFile);
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edit Blog'),
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
                                await _postManager.deletePost(post_data.id);
                                bool isSubmitted =
                                    await _postManager.updateBlog(
                                        title: title,
                                        description: description,
                                        timeStamp: timestamp,
                                        postImage: _postImageFile);
                                setState(() {
                                  _isLoading = false;
                                });

                                if (isSubmitted) {
                                  const snackBar = SnackBar(
                                      content:
                                          Text('Blog edited successfully'));
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
      body: SingleChildScrollView(
          child: Center(
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
            (_postImageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _postImageFile!,
                      height: 300,
                      width: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Padding(padding: EdgeInsets.all(0))),
            const SizedBox(
              height: 4,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 40, 10),
              width: 205,
              height: 80.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                      width: 2.0, color: Colors.black.withOpacity(0.5)),
                  primary: color, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () async {
                  if (_postImageFile == null) {
                    await pickImage();
                    if (_postImageFile != null) {
                      color = Colors.red;
                      photoText = "Remove Image";
                    }
                  } else {
                    _postImageFile = null;
                    color = appTheme;
                    photoText = "Add Image";
                  }
                  setState(() {
                    build(context);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.add_photo_alternate, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(photoText,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
          ]))),
      resizeToAvoidBottomInset: true,
    );
  }
}
