import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class CustomWidgets {

  static Widget socialButtonCircle(color, imagePath, {iconColor, Function? onTap}) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Image.asset(imagePath, height: 20, width: 20,)),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final appTheme = const Color(0xff4CC47C);
  final Color facebookColor = const Color(0xff39579A);
  final Color googleColor = const Color(0xffDF4A32);
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Widget buildEmail() {
    return Row(
      children: [
        Expanded(
            child: Image.asset(
          'images/icons/email.png',
          height: 50,
          width: 50,
        )),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Email address",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPassword() {
    return Row(
      children: [
        Expanded(
            child: Image.asset(
          'images/icons/padlock.png',
          height: 50,
          width: 50,
        )),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Password",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                controller: passwordController,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInWithText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        /*Container(
          padding: const EdgeInsets.only(top: 15.0),
          child: TextButton(
            onPressed: () => print('Forgot Password Button Pressed'),
            child: Text('Forgot Password?',
                style: TextStyle(
                  color: appTheme,
                  fontSize: 16,
                )),
          ),
        ),*/
        Container(
          padding: const EdgeInsets.only(top: 15.0),
          child: TextButton(
            onPressed: () =>
                print('Not an existing user? Click here to sign up!'),
            child: Text('Not an existing user? Click here to sign up!',
                style: TextStyle(
                  color: appTheme,
                  fontSize: 16,
                )),
          ),
        ),
        Text(
          '- OR -',
          style: TextStyle(
            color: appTheme,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('Sign in with',
            style: TextStyle(
              color: appTheme,
              fontSize: 16,
            )),
      ],
    );
  }

  Widget _buildSkipSignin() {
    return Container(
      child: TextButton(
        onPressed: () => print('Continue without signing in'),
        child: Text('Continue without signing in',
            style: TextStyle(
              color: appTheme,
              fontSize: 16,
            )),
      ),
    );
  }

  Widget _buildSocialBtn(Function action, String logoPath) {
    return InkWell(
      onTap: () {
        action();
      },
      child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image.asset(logoPath, height: 20, width: 20,)),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () => print('Login with Facebook'),

              'images/logos/facebook.png',

          ),
          _buildSocialBtn(
            () => print('Login with Google'),

              'images/logos/google.png',

          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign in',
        ),
        backgroundColor: appTheme,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: buildEmail(),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: buildPassword(),
          ),
          Container(
            child: ElevatedButton(
              child: Text("SIGN IN"),
              style: ElevatedButton.styleFrom(
                  primary: Color(0xff84C59E),
                  shadowColor: appTheme,
                  elevation: 17,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                  fixedSize: Size(350, 45),
                  textStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
              onPressed: () {},
            ),
          ),
          _buildSignInWithText(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomWidgets.socialButtonCircle(
                    facebookColor, 'images/logos/facebook.png',
                    iconColor: Colors.white, onTap: () {
                  print('I am circle facebook');
                }),
                CustomWidgets.socialButtonCircle(
                    googleColor, 'images/logos/google.png',
                    iconColor: Colors.white, onTap: () {
                  print('I am circle google');
                }),
              ],
            ),
          ),
          _buildSkipSignin(),
          Container(
            child: Image.asset(
              'images/decorations/LoginDecoration.png',
              width: 170,
              height: 170,
            ),
          )
        ],
      ),
    );
  }
}
