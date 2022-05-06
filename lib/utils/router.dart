import 'package:flutter/material.dart';
import '../Screens/loginScreen.dart';
import '../Screens/signUp.dart';
import '../utils/constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case loginRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case signupRoute:
      return MaterialPageRoute(builder: (context) => SignupScreen());
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}
