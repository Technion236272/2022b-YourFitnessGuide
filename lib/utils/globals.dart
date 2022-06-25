import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';



// final DateTime timestamp = DateTime.now();

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore database = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;



/// Collections
final CollectionReference<Map<String, dynamic>> userCollection =
    database.collection("versions").doc("v2").collection("users");
final CollectionReference<Map<String, dynamic>> postCollection =
    database.collection("versions").doc("v2").collection("posts");
final CollectionReference<Map<String, dynamic>> commentsCollection =
    database.collection("versions").doc("v2").collection("comments");
final CollectionReference<Map<String, dynamic>> notificationsCollection =
    database.collection("versions").doc("v2").collection('notifications');

/// Returns current user id
String? getCurrUid() {
  return firebaseAuth.currentUser?.uid;
}

/// Managers
// final CommentsManager _commentsManager = CommentsManager();


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
const String editBlogRoute='/editblog';
const String editWorkoutRoute='/editworkout';
const String editMealPlanRoute='/editmealplan';
const String commentsRoute='/comments';


const Color appTheme = const Color(0xff4CC47C);
enum Goal { loseWeight, gainMuscle, gainWeight, maintainHealth }
class SearchArguments {
  final String uid;
  final String? postid;
  final bool isUser;
  SearchArguments({required this.uid, required this.isUser, this.postid});
}

