import 'package:flutter/material.dart';
import 'package:yourfitnessguide/Screens/profileScreen.dart';
import 'package:yourfitnessguide/Screens/signinScreen.dart';
import 'package:yourfitnessguide/Screens/signupScreen.dart';
import 'package:yourfitnessguide/Screens/resetPasswordScreen.dart';
import 'package:yourfitnessguide/Screens/editProfileScreen.dart';
import 'package:yourfitnessguide/home.dart';
import 'package:yourfitnessguide/utils/constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case loginRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case signupRoute:
      return MaterialPageRoute(builder: (context) => SignupScreen());
    case resetPasswordRoute:
      return MaterialPageRoute(builder: (context) => ResetPasswordScreen());
    case homeRoute:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case editProfileRoute:
      return MaterialPageRoute(builder: (context) => EditProfileScreen());
    case profileRoute:
      return MaterialPageRoute(builder: (context) => ProfileScreen());
    default:
      return MaterialPageRoute(builder: (context) => HomeScreen());
  }
}
