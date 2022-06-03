import 'package:flutter/material.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/profileScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/signinScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/signupScreen.dart';
import 'package:yourfitnessguide/Screens/AuthenticationScreens/resetPasswordScreen.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/editProfileScreen.dart';
import 'package:yourfitnessguide/home.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/Screens/PostsCreationScreens/mealPlanScreen.dart';
import 'package:yourfitnessguide/Screens/PostsCreationScreens/workoutScreen.dart';
import 'package:yourfitnessguide/Screens/PostsCreationScreens/BlogPostScreen.dart';
import 'package:yourfitnessguide/Screens/ViewPostScreens/viewBlogPost.dart';
import 'package:yourfitnessguide/Screens/ViewPostScreens/viewWorkoutPost.dart';
import 'package:yourfitnessguide/Screens/ViewPostScreens/viewMealPlanPost.dart';
import 'package:yourfitnessguide/Screens/ProfileScreens/viewUsers.dart';

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
    case viewFollowersRoute:
      final args = settings.arguments as Map<String, String?>;
      return MaterialPageRoute(builder: (context) => ViewUsersScreen(origin: 'followers', currID: args['currID'],));
    case viewFollowingRoute:
      final args = settings.arguments as Map<String, String?>;
      return MaterialPageRoute(builder: (context) => ViewUsersScreen(origin: 'following', currID: args['currID'],));
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
