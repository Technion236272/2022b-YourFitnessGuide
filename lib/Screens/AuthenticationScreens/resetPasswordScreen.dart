import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/users.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();
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
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 5),
              label: Center(
                child: Text('Email Address'),
              ),
              labelStyle: TextStyle(
                  color: appTheme,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
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
      try
      {
        bool sent = await user.resetPassword(email);
        AlertDialog alert = AlertDialog(
          title: const Text("Email sent"),
          content: const Text("check your inbox!"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("OK"))
          ],
        );

        if (sent) {
          showDialog(
              context: context,
              builder: (builder) {
                return alert;
              });
        } else {
          throw Exception;
        }
      }
      catch(_){
        const snackBar =
        SnackBar(content: Text('There was a problem sending the email'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }


    }
  }

  Widget _buildSubmitReset(double height, double width) {
    return ElevatedButton(
      child: const Text("SUBMIT"),
      style: ElevatedButton.styleFrom(
          primary: Color(0xff84C59E),
          side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          fixedSize: Size(width * 0.9, height * 0.055),
          textStyle: const TextStyle(
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
    textField emailField = textField(fieldName: 'Email Address', centered: true,);

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
              const Text('Enter the email you use to sign in below',
                  style: TextStyle(
                      color: appTheme,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                height: resetHeight * 0.05,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: resetHeight * 0.01, horizontal: resetWidth * 0.1),
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
