import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/users.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final appTheme = const Color(0xff4CC47C);
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  bool _identicalPasswords = true;
  var user;

  Widget buildEmail(double height) {
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

  Widget buildPassword(double height, bool confirm) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                confirm ? "Confirm Password" : "Password",
                style: TextStyle(
                  color: appTheme,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                controller: confirm ? confirmController : passwordController,
                decoration: InputDecoration(
                  errorText: !confirm? null : (_identicalPasswords? null : 'Passwords must match')
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignInWithText(double height) {
    return Container(
      padding: EdgeInsets.all(height * 0.025),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
      ),
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
          boxShadow: [
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
            () => _getFBcredintials(),
            'images/logos/facebook.png',
            height,
          ),
          _buildSocialBtn(
            () => _getGooglecredintials(),
            'images/logos/google.png',
            height,
          ),
        ],
      ),
    );
  }

  bool _skipToHomepage() {
    const snackBar = SnackBar(content: Text('Homepage still not created'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return true;
  }

  bool _getFBcredintials() {
    const snackBar =
        SnackBar(content: Text('Sign up with FB not implemented yet'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return true;
  }

  bool _getGooglecredintials() {
    const snackBar =
        SnackBar(content: Text('Sign up with Google not implemented yet'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return true;
  }

  void _validateSignUp() {
    if(passwordController.text != confirmController.text)
    {
      setState(() {
        _identicalPasswords = false;
      });
    }
    else{
      setState(() {
        _identicalPasswords = true;
      });
      FocusManager.instance.primaryFocus?.unfocus();
      user.signUp(emailController.text, passwordController.text);
      emailController.clear();
      passwordController.clear();
      confirmController.clear();
      const snackBar = SnackBar(content: Text('Sign up not implemented yet'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  bool _gotoSignUp() {
    FocusManager.instance.primaryFocus?.unfocus();
    const snackBar = SnackBar(content: Text('Sign up not implemented yet'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return true;
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: height * 0.03,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: width * 0.1),
                child: buildEmail(height),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: width * 0.1),
                child: buildPassword(height, false),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: width * 0.1),
                child: buildPassword(height, true),
              ),
              Container(
                child: ElevatedButton(
                  child: Text("SIGN UP"),
                  style: ElevatedButton.styleFrom(
                      primary: Color(0xff84C59E),
                      shadowColor: appTheme,
                      elevation: 17,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                      fixedSize: Size(width * 0.9, height * 0.055),
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      )),
                  onPressed: () {
                    _validateSignUp();
                  },
                ),
              ),
              _buildSignInWithText(height),
              _buildSocialBtnRow(height),
              SizedBox(
                height: height*0.03,
              ),
              Image.asset(
                'images/decorations/LoginDecoration.png',
                width: width,
                height: height * 0.22,
              )
            ],
          ),
        ),
      ),
    );
  }
}
