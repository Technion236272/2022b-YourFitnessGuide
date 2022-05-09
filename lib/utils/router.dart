import 'package:flutter/material.dart';

import 'package:yourfitnessguide/Screens/profileScreen.dart';
import 'package:yourfitnessguide/Screens/BlogPostScreen.dart';
import 'package:yourfitnessguide/Screens/signinScreen.dart';
import 'package:yourfitnessguide/Screens/signupScreen.dart';
import 'package:yourfitnessguide/Screens/resetPasswordScreen.dart';
import 'package:yourfitnessguide/Screens/editProfileScreen.dart';
import 'package:yourfitnessguide/home.dart';
import 'package:yourfitnessguide/utils/constants.dart';
import 'package:yourfitnessguide/Screens/mealPlanScreen.dart';
import 'package:yourfitnessguide/Screens/mealAddScreen.dart';

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
    case blogPostRoute:
      return MaterialPageRoute(builder: (context) => BlogPostScreen());
    case editProfileRoute:
      return MaterialPageRoute(builder: (context) => EditProfileScreen());
    case mealPlanRoute:
      return MaterialPageRoute(builder: (context) => MealPlanScreen());
    case mealAddRoute:
      return MaterialPageRoute(builder: (context) => MealScreen());
    case profileRoute:
      return MaterialPageRoute(builder: (context) => ProfileScreen());
    default:
      return MaterialPageRoute(builder: (context) => HomeScreen());
  }
}
