import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/constants.dart';

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
  bool _strongPassword = true;
  bool _hiddenPassword = true;
  bool _hiddenConfirm = true;
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
                obscureText: confirm ? _hiddenConfirm : _hiddenPassword,
                textAlign: TextAlign.center,
                controller: confirm ? confirmController : passwordController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: appTheme,
                      ),
                      onPressed: () {
                        setState(() {
                          if (confirm) {
                            _hiddenConfirm = !_hiddenConfirm;
                          } else {
                            _hiddenPassword = !_hiddenPassword;
                          }
                        });
                      },
                    ),
                    errorText: !confirm
                        ? (_strongPassword
                            ? null
                            : 'Your password must be at least 6 characters')
                        : (_identicalPasswords
                            ? null
                            : 'Passwords must match')),
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
          Text('Sign up with',
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

  Future<void> _getFBcredintials() async {
    if (await user.signInWithFacebook()) {
      const snackBar = SnackBar(content: Text('Homepage still not created'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      const snackBar =
          SnackBar(content: Text('There was an error logging into the app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _getGooglecredintials() async {
    if (await user.signInWithGoogle()) {
      const snackBar = SnackBar(content: Text('Homepage still not created'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      const snackBar =
          SnackBar(content: Text('There was an error logging into the app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _validateSignUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailController.text;
    emailController.clear();
    var password = passwordController.text;
    passwordController.clear();
    var confirm = confirmController.text;
    confirmController.clear();

    if (password.length < 6) {
      setState(() {
        _strongPassword = false;
        return;
      });
    } else {
      setState(() {
        _strongPassword = true;
      });
    };

    if (password != confirm) {
      setState(() {
        _identicalPasswords = false;
        return;
      });
    } else {
      setState(() {
        _identicalPasswords = true;
      });

      var res = await user.signUp(email, password);
      if (res is UserCredential) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, homeRoute);
      }
      else if(res is int){
        switch(res){
          case 0:
            const snackBar = SnackBar(content: Text('An error occurred: Email already in use.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            break;

          case 1:
            const snackBar = SnackBar(content: Text('An error occurred: Weak password.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            break;

          case 2:
            const snackBar = SnackBar(content: Text('An error occurred: Invalid email.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            break;

          default:
            const snackBar = SnackBar(content: Text('An error occurred while trying to sign you in, please try again later.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
      }
      else{
        const snackBar = SnackBar(content: Text('An error occurred while trying to sign you in, please try again later.'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
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
                height: height * 0.072,
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
