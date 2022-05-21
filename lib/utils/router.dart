import 'package:flutter/material.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profileScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/signinScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/signupScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/resetPasswordScreen.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/editProfileScreen.dart';
import 'package:yourfitnessguide/home.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/Screens/PostsScreens/mealPlanScreen.dart';
import 'package:yourfitnessguide/Screens/PostsScreens/workoutScreen.dart';
import 'package:yourfitnessguide/Screens/PostsScreens/BlogPostScreen.dart';
import 'package:yourfitnessguide/Screens/ViewPostScreens/viewBlogPost.dart';
import 'package:yourfitnessguide/Screens/ViewPostScreens/viewWorkoutPost.dart';
import 'package:yourfitnessguide/Screens/ViewPostScreens/viewMealPlanPost.dart';

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
    case viewBlogRoute:
      if(settings.arguments != null) {
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewBlogPostScreen(post_data: args));
      }
      return MaterialPageRoute(builder: (context) => ViewBlogPostScreen());
    case viewWorkoutRoute:
      if(settings.arguments != null) {
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewWorkoutScreen(post_data:args));
      }
      return MaterialPageRoute(builder: (context) => ViewWorkoutScreen());
    case viewMealPlanRoute:
      if(settings.arguments != null) {
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewMealPlanScreen(post_data:args));
      }
      return MaterialPageRoute(builder: (context) => ViewMealPlanScreen());
    case profileRoute:
      if(settings.arguments != null){
        final args = settings.arguments as SearchArguments;
        return MaterialPageRoute(builder: (context) => ProfileScreen(uid: args.uid));
      }
      return MaterialPageRoute(builder: (context) => ProfileScreen());
    default:
      return MaterialPageRoute(builder: (context) => HomeScreen());
  }
}
