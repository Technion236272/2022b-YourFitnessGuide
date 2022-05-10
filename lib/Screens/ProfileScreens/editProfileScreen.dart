import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'dart:io';
import 'package:yourfitnessguide/utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final appTheme = const Color(0xff4CC47C);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initalController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  Goal? userGoal;
  String? profileImage;
  XFile? selectedImage;
  File? newImage;
  var user;
  var userData;

  Widget _buildImageContainer(double height, double width) {
    return Container(
        width: height * 0.25,
        height: height * 0.25,
        decoration: BoxDecoration(
            border: Border.all(width: 4, color: const Color(0xffD6D6D6)),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 3,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1))
            ],
            shape: BoxShape.circle,
            image: newImage != null
                ? DecorationImage(
                    fit: BoxFit.cover, image: Image.file(newImage!).image)
                : (profileImage == null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            Image.asset('images/decorations/mclovin.png').image)
                    : DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(profileImage!)))));
  }

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
          onPressed: () => pickImage(),
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
            hintStyle: const TextStyle(height: 1, fontSize: 16, color: Colors.grey),
          ),
          controller: _nameController,
        ));
  }

  Widget _buildWeightProgress(double height, double width) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                labelText: "Initial\nweight",
                labelStyle: TextStyle(
                  color: appTheme,
                  fontSize: 23,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: "80",
                hintStyle:
                    const TextStyle(height: 2.8, fontSize: 16, color: Colors.grey),
              ),
              controller: _initalController,
            )),
            SizedBox(
              width: 0.05 * width,
            ),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  labelText: "Current\nweight",
                  labelStyle: TextStyle(
                    color: appTheme,
                    fontSize: 23,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "80",
                  hintStyle:
                      const TextStyle(height: 2.8, fontSize: 16, color: Colors.grey),
                ),
                controller: _currentController,
              ),
            ),
            SizedBox(
              width: 0.05 * width,
            ),
            Expanded(
                child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                labelText: "Goal\nweight",
                labelStyle: TextStyle(
                  color: appTheme,
                  fontSize: 23,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: "80",
                hintStyle:
                    const TextStyle(height: 2.8, fontSize: 16, color: Colors.grey),
              ),
              controller: _goalController,
            ))
          ],
        ));
  }

  Widget _buildGoalChoices(double height, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<Goal>(
            title: const Text('Lose Weight'),
            value: Goal.loseWeight,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        RadioListTile<Goal>(
            title: const Text('Gain Muscle'),
            value: Goal.gainMuscle,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        RadioListTile<Goal>(
            title: const Text('Gain Healthy Weight'),
            value: Goal.gainWeight,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        RadioListTile<Goal>(
            title: const Text('Maintain Healthy Lifestyle'),
            value: Goal.maintainHealth,
            groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  userGoal = value;
                })),
      ],
    );
  }

  Widget _buildFinishButtons(double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('CANCEL',
                style: TextStyle(
                  color: appTheme,
                  fontSize: 14,
                )),
          ),
        ),
        Flexible(
          child: TextButton(
            onPressed: () {
              user.updateUserData(
                  _nameController.text,
                  int.parse(_initalController.text),
                  int.parse(_currentController.text),
                  int.parse(_goalController.text),
                  userGoal?.index,
              newImage);
              Navigator.pop(context);
            },
            child: Text('CONFIRM',
                style: TextStyle(
                  color: appTheme,
                  fontSize: 14,
                )),
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
    userData;
    if (user.isAuthenticated) {
      userData = user.userData;
      profileImage = userData?.pictureUrl;
      _nameController.text =
          _nameController.text.isEmpty ? userData?.name : _nameController.text;
      _initalController.text = (_initalController.text.isEmpty
          ? userData?.iWeight.toString()
          : _initalController.text)!;
      _currentController.text = (_currentController.text.isEmpty
          ? userData?.cWeight.toString()
          : _currentController.text)!;
      _goalController.text = (_goalController.text.isEmpty
          ? userData?.gWeight.toString()
          : _goalController.text)!;
      userGoal = userGoal ?? Goal.values[userData?.goal];
    } else {
      userData = null;
    }
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        title: const Text('Edit your profile'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit');
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        )),
                  ],
                )),
          ]
      ),
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
                      _buildImageContainer(height, width),
                      _buildEditImage(height, width),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
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
              _buildGoalChoices(height, width),
              _buildFinishButtons(height, width),
            ],
          ),
        ),
      ),
    );
  }
}
