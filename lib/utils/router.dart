import 'package:flutter/material.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profileScreen.dart';
import 'package:yourfitnessguide/Screens/BlogPostScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/signinScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/signupScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/resetPasswordScreen.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/editProfileScreen.dart';
import 'package:yourfitnessguide/home.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/Screens/mealPlanScreen.dart';
import 'package:yourfitnessguide/Screens/mealAddScreen.dart';
import 'package:yourfitnessguide/Screens/workoutScreen.dart';

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
    case workoutPostRoute:
      return MaterialPageRoute(builder: (context) => WorkoutScreen());
    case editProfileRoute:
      return MaterialPageRoute(builder: (context) => EditProfileScreen(firstTime: false,));
    case setupProfileRoute:
      return MaterialPageRoute(builder: (context) => EditProfileScreen(firstTime: true,));
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
