import 'dart:ui';
const String loginRoute = '/login';
const String signupRoute = '/signup';
const String resetPasswordRoute = '/reset';
const String homeRoute = '/home';
const String blogPostRoute = '/blogpost';
const String editProfileRoute = '/edit';
const String setupProfileRoute = '/setup';
const String profileRoute = '/profile';
const String mealPlanRoute = '/mealplan';
const String mealAddRoute = '/meal';
const String workoutPostRoute = '/workoutpost';
const String searchRoute = '/search';
const String viewProfileRoute = '/view';
const String viewBlogRoute='/viewblog';
const String viewWorkoutRoute='/viewworkout';
const String viewMealPlanRoute='/viewmealplan';
const String viewFollowingRoute='/following';
const String viewFollowersRoute='/followers';


const Color appTheme = const Color(0xff4CC47C);
enum Goal { loseWeight, gainMuscle, gainWeight, maintainHealth }
class SearchArguments {
  final String uid;
  final String? postid;
  final bool isUser;
  SearchArguments({required this.uid, required this.isUser, this.postid});
}