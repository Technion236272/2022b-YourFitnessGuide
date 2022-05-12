import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'dart:io';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  late bool firstTime;

  EditProfileScreen({Key? key, required this.firstTime}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initialController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  late Widget _imageContainer;

  late GoalChoices choices;
  Goal? userGoal;
  String? profileImage;
  XFile? selectedImage;
  File? newImage;
  var user;
  var userData;

  get firstTime => widget.firstTime;

  Widget _buildEditImage(double height, double width) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        height: height * 0.065,
        width: height * 0.065,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 4, color: Colors.white),
          color: appTheme,
        ),
        child: IconButton(
          icon: Icon(
            Icons.edit,
            size: height * 0.035,
            color: Colors.white,
          ),
          onPressed: () {
            pickImage();
            if (newImage != null) {}
          },
        ),
      ),
    );
  }

  Widget _buildNameField(double height) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: TextField(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 5),
            labelText: "Full Name",
            labelStyle: TextStyle(
              color: appTheme,
              fontSize: 23,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: "Mclovin",
            hintStyle:
                const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
          ),
          controller: _nameController,
        ));
  }

  Widget _buildWeightField(String label, TextEditingController ctrl) {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.number,
      controller: ctrl,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        labelText: label,
        labelStyle: TextStyle(color: appTheme, fontSize: 23),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: "80",
        hintStyle:
            const TextStyle(height: 2.8, fontSize: 16, color: Colors.grey),
      ),
    ));
  }

  Widget _buildWeightProgress(double height, double width) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWeightField("Initial\nweight", _initialController),
            SizedBox(
              width: 0.05 * width,
            ),
            _buildWeightField("Current\nweight", _currentController),
            SizedBox(
              width: 0.05 * width,
            ),
            _buildWeightField("Goal\nweight", _goalController),
          ],
        ));
  }

  Future pickImage() async {
    try {
      final selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage == null) {
        const snackBar = SnackBar(content: Text('No image was selected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
      setState(() {
        newImage = File(selectedImage.path);
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
    user = Provider.of<AuthRepository>(context);

    if (user.isAuthenticated) {
      userData = user.userData;

      profileImage = userData?.pictureUrl;
      _nameController.text = _nameController.text.isEmpty
          ? (userData != null ? userData.name : _nameController.text)
          : _nameController.text;
      _initialController.text = (_initialController.text.isEmpty
          ? (userData != null
              ? userData.iWeight.toString()
              : _initialController.text)
          : _initialController.text);
      _currentController.text = (_currentController.text.isEmpty
          ? (userData != null
              ? userData.cWeight.toString()
              : _currentController.text)
          : _currentController.text);
      _goalController.text = (_goalController.text.isEmpty
          ? (userData != null
              ? userData.gWeight.toString()
              : _goalController.text)
          : _goalController.text);
      userGoal = userGoal ?? Goal.values[userData != null ? userData.goal : 0];
    } else {
      userData = null;
    }
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    choices = GoalChoices(height: height, width: width, userGoal: userGoal);

    if (newImage != null) {
      _imageContainer = imageContainer(
        height: height,
        width: width,
        imageFile: newImage,
        percent: 0.25,
      );
    } else {
      _imageContainer = imageContainer(
        height: height,
        width: width,
        imageLink: profileImage,
        percent: 0.25,
      );
    }

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(firstTime ? 'Set up your profile' : 'Edit your profile'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          user.updateUserData(
                              _nameController.text,
                              int.parse(_initialController.text),
                              int.parse(_currentController.text),
                              int.parse(_goalController.text),
                              choices.userGoal?.index,
                              newImage);
                          if (firstTime) {
                            Navigator.pushReplacementNamed(context, homeRoute);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon:
                            const Icon(Icons.check_sharp, color: Colors.white)),
                  ],
                )),
          ]),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              SizedBox(height: height * 0.02),
              Container(
                padding: EdgeInsets.only(
                    top: 0.25, left: width * 0.05, right: width * 0.05),
                child: Center(
                  child: Stack(
                    children: [
                      _imageContainer,
                      _buildEditImage(height, width),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Container(
                  padding:
                      EdgeInsets.only(left: width * 0.05, right: width * 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(height),
                      _buildWeightProgress(height, width),
                      Text('Goal',
                          style: TextStyle(
                            color: appTheme,
                            fontSize: 23,
                          )),
                    ],
                  )),
              choices,
              firstTime
                  ? Container()
                  : ElevatedButton(
                      child: const Text("DELETE ACCOUNT"),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          shadowColor: appTheme,
                          elevation: 17,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fixedSize: Size(width * 0.9, height * 0.055),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      onPressed: () async {
                        Widget cancel = TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: appTheme),
                            ));
                        Widget confirm = TextButton(
                            onPressed: () {
                              user.deleteUser();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (_) => false);
                            },
                            child: Text('Confirm',
                                style: TextStyle(color: appTheme)));
                        AlertDialog alert = AlertDialog(
                          title: Text('Are you sure?'),
                          actions: [cancel, confirm],
                        );
                        showDialog(
                            context: context,
                            builder: (BuildContext) {
                              return alert;
                            });
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
