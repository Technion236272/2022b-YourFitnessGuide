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
import 'package:yourfitnessguide/Screens/EditPosts/editBlogPost.dart';
import 'package:yourfitnessguide/Screens/EditPosts/editWorkoutPost.dart';
import 'package:yourfitnessguide/Screens/EditPosts/editMealPlanPost.dart';
import 'package:yourfitnessguide/Screens/commentsScreen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case loginRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case signupRoute:
      return MaterialPageRoute(builder: (context) => const SignupScreen());
    case resetPasswordRoute:
      return MaterialPageRoute(builder: (context) => const ResetPasswordScreen());
    case commentsRoute:
      if (settings.arguments != null) {
        final args = settings.arguments as Map;
        return MaterialPageRoute(builder: (context) => CommentsScreen(postId: args['postId'], userId: args['userId']));
      }
      return MaterialPageRoute(builder: (context) => const CommentsScreen(postId: "aa", userId: "aa"));
    case homeRoute:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case blogPostRoute:
      return MaterialPageRoute(builder: (context) => const BlogPostScreen());
    case workoutPostRoute:
      return MaterialPageRoute(builder: (context) => const WorkoutScreen());
    case editProfileRoute:
      return MaterialPageRoute(builder: (context) => EditProfileScreen(firstTime: false));
    case setupProfileRoute:
      return MaterialPageRoute(
          builder: (context) => EditProfileScreen(firstTime: true));
    case mealPlanRoute:
      return MaterialPageRoute(builder: (context) => const MealPlanScreen());
    case viewBlogRoute:
      if (settings.arguments != null) {
        final args = settings.arguments;
        return MaterialPageRoute(
            builder: (context) => ViewBlogPostScreen(post_data: args));
      }
      return MaterialPageRoute(builder: (context) => ViewBlogPostScreen());
    case viewFollowersRoute:
      final args = settings.arguments as Map<String, String?>;
      return MaterialPageRoute(
          builder: (context) => ViewUsersScreen(
                origin: 'followers',
                currID: args['currID'],
              ));
    case viewFollowingRoute:
      final args = settings.arguments as Map<String, String?>;
      return MaterialPageRoute(
          builder: (context) => ViewUsersScreen(
                origin: 'following',
                currID: args['currID'],
              ));
    case viewWorkoutRoute:
      if (settings.arguments != null) {
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewWorkoutScreen(post_data: args));
      }
      return MaterialPageRoute(builder: (context) => ViewWorkoutScreen());
    case viewMealPlanRoute:
      if (settings.arguments != null) {
        final args = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewMealPlanScreen(post_data: args));
      }
      return MaterialPageRoute(builder: (context) => ViewMealPlanScreen());
    case profileRoute:
      if (settings.arguments != null) {
        final args = settings.arguments as SearchArguments;
        return MaterialPageRoute(builder: (context) => ProfileScreen(uid: args.uid));
      }
      return MaterialPageRoute(builder: (context) => ProfileScreen());
    case editBlogRoute:
      final args = settings.arguments;
      return MaterialPageRoute(builder: (context) => EditBlogPost(post_data: args));
    case editWorkoutRoute:
      final args = settings.arguments;
      return MaterialPageRoute(builder: (context) => EditWorkout(post_data: args));
    case editMealPlanRoute:
      final args = settings.arguments;
      return MaterialPageRoute(builder: (context) => EditMealPlan(post_data: args));

    default:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
