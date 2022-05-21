import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  textField emailField = textField(fieldName: 'Email Address', centered: true,);
  TextEditingController confirmController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _strongPassword = true;
  bool _hiddenPassword = true;
  bool _hiddenConfirm = true;
  bool _identicalPasswords = true;
  Goal? userGoal;
  var user;

  Widget _buildEmail(double height, Widget field) {
    final iconSize = height * 0.065;
    return Row(
      children: [
        Expanded(
            child: Image.asset(
              'images/icons/email.png',
              height: iconSize,
              width: iconSize,
            )),
        Expanded(
          flex: 5,
          child: field,
        ),
      ],
    );
  }

  Widget _buildPassword(double height, bool isConfirm) {
    final iconSize = height * 0.065;
    String fieldText = isConfirm ? 'Confirm Password' : 'Password';
    return Row(
      children: [
        Expanded(
            child: Image.asset(
          'images/icons/padlock.png',
          height: iconSize,
          width: iconSize,
        )),
        Expanded(
            flex: 5,
            child: TextField(
              obscureText: isConfirm ? _hiddenConfirm : _hiddenPassword,
              textAlign: TextAlign.center,
              controller: isConfirm ? confirmController : passwordController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  errorText: !isConfirm
                      ? (!_strongPassword
                          ? 'Your password must be at least 6 characters'
                          : null)
                      : (!_identicalPasswords ? 'Passwords must match' : null),
                  label: Padding(
                      padding: EdgeInsets.only(left: height * 0.079),
                      child: Center(
                        child: Text(fieldText),
                      )),
                  labelStyle: const TextStyle(
                    color: appTheme,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: appTheme,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isConfirm) {
                          _hiddenConfirm = !_hiddenConfirm;
                        } else {
                          _hiddenPassword = !_hiddenPassword;
                        }
                      });
                    },
                  )),
            )),
      ],
    );
  }

  Widget _buildSocialBtn(Function action, String logoPath, double height) {
    final logo = AssetImage(logoPath);
    final logoSize = height * 0.09;
    return InkWell(
      onTap: () {
        action();
      },
      child: Container(
        height: logoSize,
        width: logoSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
            scale: logoSize * 0.14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow(double height) {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.001, bottom: 0.44),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () => _getCredentials(false),
            'images/logos/facebook.png',
            height,
          ),
          _buildSocialBtn(
            () => _getCredentials(true),
            'images/logos/google.png',
            height,
          ),
        ],
      ),
    );
  }

  Future<void> _getCredentials(bool google) async {
    int signinRes = 0;

    if (google) {
      signinRes = await user.signUpWithGoogle(false);
    } else {
      signinRes = await user.signUpWithFacebook(false);
    }

    if (signinRes > 0) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/setup', (_) => false);
    } else {
      const snackBar =
          SnackBar(content: Text('There was an error logging into the app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _validateSignUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailField.controller.text;
    emailField.controller.clear();
    var password = passwordController.text;
    passwordController.clear();
    var confirm = confirmController.text;
    confirmController.clear();

    if (password.length < 6) {
      setState(() {
        _strongPassword = false;
      });
      return;
    } else {
      setState(() {
        _strongPassword = true;
      });
    }
    if (password != confirm) {
      setState(() {
        _identicalPasswords = false;
      });
      return;
    } else {
      setState(() {
        _identicalPasswords = true;
      });
    }

    var res = await user.signUp(email, password);
    if (res is UserCredential) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, setupProfileRoute);
    } else if (res is int) {
      String errorMessage = 'Error';
      switch (res) {
        case 0:
          errorMessage = 'An error occurred: Email already in use.';
          break;
        case 1:
          errorMessage = 'An error occurred: Weak password.';
          break;
        case 2:
          errorMessage = 'An error occurred: Invalid email.';
          break;
        default:
          errorMessage = 'An error occurred while trying to sign you in, please try again later.';
          break;
      }
      SnackBar snackBar = SnackBar(content: Text(errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    } else {
      const snackBar = SnackBar(
          content: Text(
              'An error occurred while trying to sign you in, please try again later.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    user = Provider.of<AuthRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign up',
        ),
        backgroundColor: appTheme,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: height * 0.025,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.012, horizontal: width * 0.1),
              child: _buildEmail(height, emailField),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.012, horizontal: width * 0.1),
              child: _buildPassword(height, false),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: height * 0.012, horizontal: width * 0.1),
              child: _buildPassword(height, true),
            ),
            Container(
              child: user.status == Status.Authenticating
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      child: const Text("SIGN UP"),
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xff84C59E),
                          shadowColor: appTheme,
                          elevation: 17,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          fixedSize: Size(width * 0.9, height * 0.055),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                      onPressed: () {
                        _validateSignUp();
                      },
                    ),
            ),
            Container(
                padding: EdgeInsets.only(top: height * 0.03),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      '- OR -',
                      style: TextStyle(
                        color: appTheme,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Sign up with',
                        style: TextStyle(
                          color: appTheme,
                          fontSize: 16,
                        )),
                  ],
                )),
            _buildSocialBtnRow(height),
            SizedBox(
              height: height * 0.15,
            ),
            Image.asset(
              'images/decorations/LoginDecoration.png',
              width: width,
              height: height * 0.21,
            )
          ],
        ),
      ),
    );
  }
}
