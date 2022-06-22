import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'dart:io';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yourfitnessguide/services/image_crop.dart';
import 'package:numberpicker/numberpicker.dart';

class EditProfileScreen extends StatefulWidget {
  late bool firstTime;

  EditProfileScreen({Key? key, required this.firstTime}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  textField nameField = textField(
    fieldName: 'Name',
    hint: 'Enter your name here',
  );
  Map<String, int> weights = {
    'initialWeight': 0,
    'currentWeight': 0,
    'goalWeight': 0,
  };

  late Widget _imageContainer;
  Map<String, bool> privacySettings = {
    'profile': false,
    'following': false,
    'followers': false
  };
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
    return Padding(padding: EdgeInsets.only(bottom: height * 0.03), child: nameField);
  }

  Widget _buildWeightField(String label, String variable) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: appTheme, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          NumberPicker(
            value: weights[variable]!,
            minValue: 1,
            maxValue: 450,
            itemHeight: 30,
            selectedTextStyle: const TextStyle(color: appTheme, fontSize: 22),
            onChanged: (value) => setState(() =>  weights[variable] = value),
          )
        ]
      )
    );
  }

  Widget _buildWeightProgress(double height, double width) {
    return Padding(
        padding: EdgeInsets.only(bottom: height * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWeightField("Initial\nWeight", 'initialWeight'),
            SizedBox(width: 0.05 * width),
            _buildWeightField("Current\nWeight",
                firstTime ? 'initialWeight' : 'currentWeight'),
            SizedBox(width: 0.05 * width),
            _buildWeightField("Goal\nWeight", 'goalWeight'),
          ],
        ));
  }

  Future pickImage() async {
    try {
      final selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage == null) {
        const snackBar = SnackBar(content: Text('No image was selected'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }

      final croppedFile = await myImageCropper(selectedImage.path);

      setState(() {
        newImage = File(croppedFile!.path); //File(selectedImage.path);
      });
    } on PlatformException catch (_) {
      const snackBar = SnackBar(
          content: Text(
              'You need to grant permission if you want to select a photo'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void deleteAccount() {
    Widget cancel = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text(
          'Cancel',
          style: TextStyle(color: appTheme),
        ));
    Widget confirm = TextButton(
        onPressed: () {
          user.deleteUser();
          Navigator.pop(context);
          Navigator.pop(context);
          setState(() {});
        },
        child: const Text('Confirm', style: TextStyle(color: appTheme)));
    AlertDialog alert = AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text(
          'Deleting your account is permanent and cannot be reversed.'),
      actions: [cancel, confirm],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void saveChanges() {
    int init = weights['initialWeight']!;
    int curr = weights['currentWeight']!;
    int goal = weights['goalWeight']!;
    if (firstTime) {
      curr = init;
    }

    if (choices.userGoal == Goal.loseWeight && (init < goal || curr < goal)) {
      const snackBar = SnackBar(
          content: Text('Invalid data: Initial weight must be bigger than goal weight.'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (choices.userGoal == Goal.gainWeight && (init > goal || curr > goal)) {
      const snackBar = SnackBar(
          content: Text('Invalid data: Goal weight must be bigger than goal weight.'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (firstTime) {
      if (init <= 0 || goal <= 0 || init >= 500 || goal >= 500) {
        const snackBar = SnackBar(content: Text('You need to fill all the fields'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        user.updateUserData(nameField.controller.text, init, curr, goal,
            choices.userGoal?.index, newImage, privacySettings);
        Navigator.pushReplacementNamed(context, homeRoute);
      }
    } else {
      if (init <= 0 ||
          curr <= 0 ||
          goal <= 0 ||
          init >= 500 ||
          curr >= 500 ||
          goal >= 500) {
        const snackBar = SnackBar(content: Text('You need to fill all the fields'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        user.updateUserData(nameField.controller.text, init, curr, goal,
            choices.userGoal?.index, newImage, privacySettings);
        Navigator.pop(context);
      }
    }
  }

  Widget _buildPrivacySettings(double height, double width) {
    if (!privacySettings.containsKey('followers')) {
      privacySettings['followers'] = false;
    }
    if (!privacySettings.containsKey('following')) {
      privacySettings['following'] = false;
    }
    if (!privacySettings.containsKey('profile')) {
      privacySettings['profile'] = false;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Limit my followers list to only me'),
            value: privacySettings['followers'],
            //groupValue: userGoal,
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  privacySettings['followers'] = value ?? false;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Limit my following list to only me'),
            value: privacySettings['following'],
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  privacySettings['following'] = value ?? false;
                })),
        Divider(
          color: Colors.grey,
          height: 0,
          thickness: 1,
          indent: width * 0.05,
          endIndent: width * 0.1,
        ),
        CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Limit my profile viewing to only me'),
            value: privacySettings['profile'],
            activeColor: appTheme,
            onChanged: (value) => setState(() {
                  privacySettings['profile'] = value ?? false;
                }))
      ],
    );
  }

  initializeWeights(){
    if(firstTime){
      weights['initialWeight'] = 1;
      weights['currentWeight'] = 1;
      weights['goalWeight'] = 1;
      return;
    }
    if(userData == null){
      if (weights['initialWeight'] == 0) {
        weights['initialWeight'] = 1;
      }
      if (weights['currentWeight'] == 0) {
        weights['currentWeight'] = 1;
      }
      if (weights['goalWeight'] == 0) {
        weights['goalWeight'] = 1;
      }
      return;
    }
    else {
      if (weights['initialWeight'] == 0) {
        weights['initialWeight'] = userData.iWeight;
      }
      if (weights['currentWeight'] == 0) {
        weights['currentWeight'] = userData.cWeight;
      }
      if (weights['goalWeight'] == 0) {
        weights['goalWeight'] = userData.gWeight;
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthRepository>(context);

    if (user.isAuthenticated) {
      userData = user.userData;
      initializeWeights();
      profileImage = userData?.pictureUrl;
      nameField.controller.text =
        nameField.controller.text.isEmpty
          ? (userData != null ? userData.name : nameField.controller.text)
          : nameField.controller.text;

      userGoal = userGoal ?? Goal.values[userData != null ? userData.goal : 0];
      privacySettings = userData?.privacySettings;
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
          centerTitle: false,
          title: Text(firstTime ? 'Setup your profile' : 'Edit your profile'),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    firstTime
                        ? Container()
                        : IconButton(
                            onPressed: () {
                              showAboutDialog(
                                context: context,
                                applicationName: 'YourFitnessGuide',
                                applicationIcon: Image.asset(
                                  'images/decorations/appIcon.jpeg',
                                  height: height * 0.08,
                                  width: height * 0.08,
                                ),
                                applicationVersion: '1.1.0',
                                applicationLegalese:
                                    '© 2022 Google logo\n© 2022 Facebook logo\n© 2022 YourFitnessGuide logo by Adan Abu Younis',
                                children: <Widget>[
                                  InkWell(
                                      child: const Text('Privacy Policy'),
                                      onTap: () async {
                                        var url = Uri.parse(
                                            'https://github.com/MahmoudMahajna1/PrivacyPolicy/blob/main/YourFitnessGuide-PrivacyPolicy.md');
                                        await launchUrl(url);
                                      }),
                                  InkWell(
                                      child: const Text('Terms & Conditions'),
                                      onTap: () async {
                                        var url = Uri.parse(
                                            'https://github.com/MahmoudMahajna1/PrivacyPolicy/blob/main/YourFitnessGuide-TOS.md');
                                        await launchUrl(url);
                                      }),
                                ],
                              );
                            },
                            icon: const Icon(Icons.info_outline, color: Colors.white,)
                    ),
                    firstTime
                        ? IconButton(
                            onPressed: () {
                              saveChanges();
                            },
                            icon: const Icon(Icons.check, color: Colors.white))
                        : Container(),
                  ],
                )),
          ]),
      body: (SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.02),
              Container(
                padding: EdgeInsets.only(top: 0.25, left: width * 0.05, right: width * 0.05),
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
                      const Text('Goal',
                          style: TextStyle(
                              color: appTheme,
                              fontSize: 23,
                              fontWeight: FontWeight.bold)),
                    ],
                  )),
              choices,
              firstTime
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(right: width * 0.45),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Privacy Settings',
                              style: TextStyle(
                                  color: appTheme,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
              firstTime ? Container() : _buildPrivacySettings(height, width),
              SizedBox(
                height: height * 0.02,
              ),
              firstTime
                  ? Container()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: appTheme,
                          side: BorderSide(
                              width: 2.0, color: Colors.black.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fixedSize: Size(width * 0.9, height * 0.055),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      onPressed: () async {
                        saveChanges();
                      },
                      child: const Text("SAVE CHANGES"),
                    ),
              firstTime
                  ? Container()
                  : SizedBox(height: height * 0.007),
              firstTime
                  ? Container()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          side: BorderSide(
                              width: 2.0, color: Colors.black.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fixedSize: Size(width * 0.6, height * 0.055),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      onPressed: () async {
                        deleteAccount();
                      },
                      child: const Text("DELETE ACCOUNT"),
                    ),
              SizedBox(height: height * 0.007),
            ],
          ),
        ),
      )),
    );
  }
}
