import 'package:flutter/material.dart';
import '../Screens/signinScreen.dart';
import '../Screens/signupScreen.dart';
import '../Screens/resetPasswordScreen.dart';
import '../utils/constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case loginRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case signupRoute:
      return MaterialPageRoute(builder: (context) => SignupScreen());
    case resetPasswordRoute:
      return MaterialPageRoute(builder: (context) => ResetPasswordScreen());
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}
