import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/users.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final appTheme = const Color(0xff4CC47C);
  TextEditingController emailController = new TextEditingController();
  var user;

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

  Future<void> _startReset() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var email = emailController.text;
    emailController.clear();
    if (email != "") {
      bool sent = await user.resetPassword(email);

      AlertDialog alert = AlertDialog(
        title: Text("Email sent"),
        content: Text("check your inbox!"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("OK"))
        ],
      );

      if (sent) {
        showDialog(
            context: context,
            builder: (builder) {
              return alert;
            });
      } else {
        const snackBar =
        SnackBar(content: Text('There was a problem sending the email'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Widget _buildSubmitReset(double height, double width) {
    return ElevatedButton(
      child: Text("SUBMIT"),
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
        _startReset();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AuthRepository>(context);
    final double resetHeight = MediaQuery.of(context).size.height;
    final double resetWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reset your password',
          ),
          backgroundColor: appTheme,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: resetHeight * 0.04,
              ),
              Text('Enter the email you use to sign in below',
                  style: TextStyle(
                      color: appTheme,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                height: resetHeight * 0.05,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: resetHeight * 0.01,
                    horizontal: resetWidth * 0.1),
                child: _buildEmail(resetHeight),
              ),
              Container(
                child: _buildSubmitReset(resetHeight, resetWidth),
              ),
              SizedBox(
                height: resetHeight * 0.39,
              ),
              Image.asset(
                'images/decorations/LoginDecoration.png',
                width: resetWidth,
                height: resetHeight * 0.21,
              ),
            ],
          ),
        ));
  }
}