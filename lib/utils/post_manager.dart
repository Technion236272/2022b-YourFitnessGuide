import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/services/file_upload_service.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class PostManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _postCollection =
      _firebaseFirestore.collection("posts");
  final CollectionReference<Map<String, dynamic>> _userCollection =
      _firebaseFirestore.collection("users");

  final FileUploadService _fileUploadService = FileUploadService();

  Future<bool> submitBlog(
      {required String title, required description, File? postImage}) async {
    bool isSubmitted = false;

    String userUid = _firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (postImage != null) {
      String? pictureUrl =
          await _fileUploadService.uploadPostFile(file: postImage);

      //todo: check if user is signed in? i think its better if we just prevent them from getting here.
      await _postCollection.doc().set({
        "category": 'Blog',
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "createdAt": timeStamp,
        "user_uid": userUid,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await _postCollection.doc().set({
        "category": 'Blog',
        "title": title,
        "description": description,
        "createdAt": timeStamp,
        "user_uid": userUid,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    }
    notifyListeners();
    return isSubmitted;
  }

  Future<bool> submitWorkout(
      {required String title,
      required description,
      File? postImage,
      required goals,
      required exercises}) async {
    bool isSubmitted = false;

    String userUid = _firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (postImage != null) {
      String? pictureUrl =
          await _fileUploadService.uploadPostFile(file: postImage);

      //todo: check if user is signed in? i think its better if we just prevent them from getting here.
      await _postCollection.doc().set({
        "category": 'Workout',
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "goals": goals,
        "exercises": exercises,
        "createdAt": timeStamp,
        "user_uid": userUid,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await _postCollection.doc().set({
        "category": 'Workout',
        "title": title,
        "description": description,
        "goals": goals,
        "exercises": exercises,
        "createdAt": timeStamp,
        "user_uid": userUid,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    }
    notifyListeners();
    return isSubmitted;
  }

  Future<bool> submitMealPlan(
      {required String title,
      required description,
      File? postImage,
      required goals,
      required mealsContents,
      required mealsName,
      required mealsIngredients}) async {
    bool isSubmitted = false;

    String userUid = _firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (postImage != null) {
      String? pictureUrl =
          await _fileUploadService.uploadPostFile(file: postImage);

      //todo: check if user is signed in? i think its better if we just prevent them from getting here.
      await _postCollection.doc().set({
        "category": 'Meal Plan',
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "goals": goals,
        "meals_contents": mealsContents,
        "meals_name": mealsName,
        "meals_ingredients": mealsIngredients,
        "createdAt": timeStamp,
        "user_uid": userUid,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await _postCollection.doc().set({
        "category": 'Meal Plan',
        "title": title,
        "description": description,
        "goals": goals,
        "meals_contents": mealsContents,
        "meals_name": mealsName,
        "meals_ingredients": mealsIngredients,
        "createdAt": timeStamp,
        "user_uid": userUid,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    }
    notifyListeners();
    return isSubmitted;
  }

  /// get all post from the db
  Stream<QuerySnapshot<Map<String, dynamic>?>> getAllPosts() {
    return _postCollection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<List<post>> getPosts() async {
    List<post> res = [];

    await _postCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var fullData = doc.data();
        fullData['uid'] = doc.id;
        var currentPost = post(
          uid: doc.id,
          screen: 'timeline',
            data: fullData,);
        res.add(currentPost);
      });
    });
    return Future<List<post>>.value(res);
  }

  Future<Map<String, dynamic>?> getPostByID(String uid) async {
    var call = await _postCollection.doc(uid);
    var post = await call.get();
    return post.data();
  }


  Stream<QuerySnapshot<Map<String, dynamic>?>> getUserPosts(String uid) {
    final Query<Map<String, dynamic>> _userPosts = _firebaseFirestore
        .collection("posts")
        .where('user_uid', isEqualTo: uid);
    notifyListeners();
    return _userPosts.orderBy('createdAt', descending: true).snapshots();
  }

  Future<List<String>> getUserPostsIDs(String uid) async {
    List<String> ids = [];

    await _firebaseFirestore.collection("posts").where('user_uid', isEqualTo: uid).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var currID = doc.id;
        ids.add(currID);
      });
    });
    return ids;
  }

  Future<void> deletePost(String postUid) async {
    _postCollection.doc(postUid).delete();
    notifyListeners();
  }

  Future<bool> checkPostsExists(String postUid) async {
    var tmp = await _postCollection.doc(postUid).get();
    return tmp.exists;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(String postUid) async {
    return _postCollection.doc(postUid).get();
  }

  ///get user info from db
  Future<Map<String, dynamic>?> getUserInfo(String userUid) async {
    Map<String, dynamic>? userData;
    await _userCollection
        .doc(userUid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        userData = doc.data();
      } else {
        userData = null;
      }
    });
    notifyListeners();
    return userData;
  }
}
