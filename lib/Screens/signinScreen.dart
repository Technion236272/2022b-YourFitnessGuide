import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/constants.dart';
import 'package:yourfitnessguide/utils/users.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var user;
  final appTheme = const Color(0xff4CC47C);
  bool _hiddenPassword = true;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Widget _buildEmail(double height) {
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
                obscureText: _hiddenPassword,
                textAlign: TextAlign.center,
                controller: passwordController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: appTheme,
                  ),
                  onPressed: () {
                    setState(() {
                      _hiddenPassword = !_hiddenPassword;
                    });
                  },
                )),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _validateLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailController.text;
    emailController.clear();
    var password = passwordController.text;
    passwordController.clear();

    if (email != "" && password != "") {
      if (await user.signIn(email, password)) {
        Navigator.pushNamed(context, homeRoute);
        const snackBar = SnackBar(content: Text('Homepage still not created'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {});
      } else {
        const snackBar = SnackBar(content: Text('Login unsuccessful'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Widget _buildSignIn(double height, double width) {
    return ElevatedButton(
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
    );
  }

  Widget _buildAlternativeActions() {
    return Column(children: [
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, resetPasswordRoute);
        },
        child: Text('Forgot password?',
            style: TextStyle(
              color: appTheme,
              fontSize: 16,
            )),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, signupRoute);
        },
        child: Text('Not an existing user? Click here to sign up!',
            style: TextStyle(
              color: appTheme,
              fontSize: 16,
            )),
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
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
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
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: height * 0.009,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: width * 0.1),
                child: _buildEmail(height),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: width * 0.1),
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

/*
class UserModel {
  final String? email;
  final String? id;
  final String? name;
  final PictureModel? pictureModel;

  const UserModel({this.id, this.email, this.name, this.pictureModel});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      pictureModel: PictureModel.fromJson(json['picture']['data']));
}

class PictureModel {
  final int? height;
  final int? width;
  final String? url;

  const PictureModel({this.url, this.height, this.width});

  factory PictureModel.fromJson(Map<String, dynamic> json) => PictureModel(
      url: json['url'], height: json['height'], width: json['width']);
}
*/
