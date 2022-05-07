import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/users.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final appTheme = const Color(0xff4CC47C);
  var user;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

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

  Widget buildPassword(double height) {
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

  Widget _buildSkipSignin(double height) {
    return Container(
      child: TextButton(
        onPressed: () => _skipToHomepage(),
        child: Text('Continue without signing in',
            style: TextStyle(
              color: appTheme,
              fontSize: 16,
            )),
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
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
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
        SnackBar(content: Text('Login with FB not implemented yet'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return true;
  }

  bool _getGooglecredintials() {
    const snackBar =
        SnackBar(content: Text('Login with Google not implemented yet'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return true;
  }

  Future<void> _validateLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailController.text;
    emailController.clear();
    var password = passwordController.text;
    passwordController.clear();

    if (email != "" && password != "") {
      if (await user.signIn(email, password)) {
        const snackBar = SnackBar(content: Text('Login successful'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});
      } else {
        const snackBar = SnackBar(content: Text('Login unsuccessful'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void _gotoSignUp() {
    Navigator.pushNamed(context, signupRoute);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    user = Provider.of<AuthRepository>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Sign in',
        ),
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
                child: buildPassword(height),
              ),
              user.status == Status.Authenticating
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      child: ElevatedButton(
                        child: Text("SIGN IN"),
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
                        onPressed: () async {
                          _validateLogin();
                        },
                      ),
                    ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: height * 0.02),
                    child: TextButton(
                      onPressed: () => _gotoSignUp(),
                      child:
                          Text('Not an existing user? Click here to sign up!',
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
              ),
              _buildSocialBtnRow(height),
              _buildSkipSignin(height),
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
