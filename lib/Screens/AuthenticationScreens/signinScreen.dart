import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var user;
  bool _hiddenPassword = true;
  textField emailField = textField(
    fieldName: 'Email Address',
    centered: true,
  );
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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

  Widget _buildPassword(double height) {
    final iconSize = height * 0.065;
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
              obscureText: _hiddenPassword,
              textAlign: TextAlign.center,
              controller: passwordController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 5),
                  label: Padding(
                      padding: EdgeInsets.only(left: height * 0.025),
                      child: const Center(
                        child: Text('Password'),
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
                        _hiddenPassword = !_hiddenPassword;
                      });
                    },
                  )),
            )),
      ],
    );
  }

  Future<void> _validateLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailField.controller.text;
    emailField.controller.clear();
    var password = passwordController.text;
    passwordController.clear();

    if (email != "" && password != "") {
      if (await user.signIn(email, password)) {
        Navigator.pushReplacementNamed(context, homeRoute);
        setState(() {});
      } else {
        const snackBar = SnackBar(content: Text('Login unsuccessful'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Widget _buildSignIn(double height, double width) {
    return ElevatedButton(
      child: const Text("SIGN IN"),
      style: ElevatedButton.styleFrom(
          primary: const Color(0xff84C59E),
          side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
          fixedSize: Size(width * 0.9, height * 0.055),
          textStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          )),
      onPressed: () async {
        _validateLogin();
      },
    );
  }

  Widget _buildAlternativeActions() {
    return Column(children: [
      TextButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          emailController.clear();
          Navigator.pushNamed(context, resetPasswordRoute);
        },
        child: const Text('Forgot password?',
            style: TextStyle(
              color: appTheme,
              fontSize: 16,
            )),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, signupRoute);
        },
        child: RichText(
            text: const TextSpan(
                children: <TextSpan>[
              TextSpan(
                  text: 'Not an existing user?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  )),
              TextSpan(
                text: ' Click here to sign up!',
                style: TextStyle(color: appTheme, fontWeight: FontWeight.bold),
              ),
            ],
                style: TextStyle(
                  color: appTheme,
                  fontSize: 16,
                ))),
      )
    ]);
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
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
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
    try {
      int signinRes = 0;

      if (google) {
        signinRes = await user.signInWithGoogle();
      } else {
        signinRes = await user.signInWithFacebook();
      }

      switch (signinRes) {
        case 1:
          Navigator.pushReplacementNamed(context, homeRoute);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, setupProfileRoute);
          break;
      }
    } catch (e) {
      const snackBar =
          SnackBar(content: Text('There was an error logging into the app'));
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
          'Sign in',
        ),
        backgroundColor: appTheme,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                child: _buildPassword(height),
              ),
              user.status == Status.Authenticating
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      child: _buildSignIn(height, width),
                    ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: height * 0.02),
                    child: _buildAlternativeActions(),
                  ),
                  const Text(
                    '- OR -',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Sign in with',
                      style: TextStyle(
                        fontSize: 16,
                      )),
                ],
              ),
              _buildSocialBtnRow(height),
              SizedBox(
                height: height * 0.025,
              ),
              Image.asset(
                'images/decorations/LoginDecoration.png',
                width: width,
                height: height * 0.21,
              )
            ],
          ),
        ),
      ),
    );
  }
}
