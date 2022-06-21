import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/services/file_upload_service.dart';
import 'package:yourfitnessguide/utils/post.dart';
import 'package:yourfitnessguide/managers/comments_manager.dart';
import 'package:yourfitnessguide/utils/globals.dart';


class PostManager with ChangeNotifier {


  final FileUploadService _fileUploadService = FileUploadService();
  final CommentsManager _commentsManager = CommentsManager();

  Future<bool> submitBlog(
      {required String title, required description, File? postImage}) async {
    bool isSubmitted = false;

    String userUid = firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (postImage != null) {
      String? pictureUrl = await _fileUploadService.uploadPostFile(file: postImage);

      //todo: check if user is signed in? i think its better if we just prevent them from getting here.
      await postCollection.doc().set({
        "category": 'Blog',
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "createdAt": timeStamp,
        "user_uid": userUid,
        'commentsNum': 0,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await postCollection.doc().set({
        "category": 'Blog',
        "title": title,
        "description": description,
        "createdAt": timeStamp,
        "user_uid": userUid,
        'commentsNum': 0,
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
      {required String title, required description, File? postImage,
        required goals, required exercises}) async {
    bool isSubmitted = false;

    String userUid = firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (postImage != null) {
      String? pictureUrl =
      await _fileUploadService.uploadPostFile(file: postImage);

      //todo: check if user is signed in? i think its better if we just prevent them from getting here.
      await postCollection.doc().set({
        "category": 'Workout',
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "goals": goals,
        "exercises": exercises,
        "createdAt": timeStamp,
        "user_uid": userUid,
        'commentsNum': 0,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await postCollection.doc().set({
        "category": 'Workout',
        "title": title,
        "description": description,
        "goals": goals,
        "exercises": exercises,
        "createdAt": timeStamp,
        "user_uid": userUid,
        'commentsNum': 0,
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
      {required String title, required description, File? postImage,
        required goals, required mealsContents, required mealsName, required mealsIngredients}) async {
    bool isSubmitted = false;

    String userUid = firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (postImage != null) {
      String? pictureUrl =
      await _fileUploadService.uploadPostFile(file: postImage);

      await postCollection.doc().set({
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
        'commentsNum': 0,
        "rating": 0
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await postCollection.doc().set({
        "category": 'Meal Plan',
        "title": title,
        "description": description,
        "goals": goals,
        "meals_contents": mealsContents,
        "meals_name": mealsName,
        "meals_ingredients": mealsIngredients,
        "createdAt": timeStamp,
        "user_uid": userUid,
        'commentsNum': 0,
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

  Future<bool> updateBlog(
      {required String postId, required String title, required description,
        File? postImage}) async {
    bool isSubmitted = false;


    if (postImage != null) {
      String? pictureUrl = await _fileUploadService.uploadPostFile(file: postImage);

      await postCollection.doc(postId).update({
        "title": title,
        "description": description,
        "image_url": pictureUrl,
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        print(onError);
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await postCollection.doc(postId).update({
        "title": title,
        "description": description,
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        print(onError);
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    }
    notifyListeners();
    return isSubmitted;
  }

  Future<bool> updateWorkout(
      {required String title, required description, File? postImage, required goals, required exercises}) async {
    bool isSubmitted = false;

    if (postImage != null) {
      String? pictureUrl =
      await _fileUploadService.uploadPostFile(file: postImage);

      await postCollection.doc().update({
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "goals": goals,
        "exercises": exercises,
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await postCollection.doc().set({
        "title": title,
        "description": description,
        "goals": goals,
        "exercises": exercises,
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

  Future<bool> updateMealPlan(
      {required postId, required String title, required description,
        File? postImage, required goals,
        required mealsContents, required mealsName, required mealsIngredients}) async {
    bool isSubmitted = false;

    if (postImage != null) {
      String? pictureUrl =
      await _fileUploadService.uploadPostFile(file: postImage);

      await postCollection.doc(postId).update({
        "title": title,
        "description": description,
        "image_url": pictureUrl,
        "goals": goals,
        "meals_contents": mealsContents,
        "meals_name": mealsName,
        "meals_ingredients": mealsIngredients,
      }).then((_) {
        isSubmitted = true;
      }).catchError((onError) {
        isSubmitted = false;
      }).timeout(const Duration(seconds: 20), onTimeout: () {
        isSubmitted = false;
      });
    } else {
      await postCollection.doc(postId).update({
        "title": title,
        "description": description,
        "goals": goals,
        "meals_contents": mealsContents,
        "meals_name": mealsName,
        "meals_ingredients": mealsIngredients,
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
  Stream<QuerySnapshot<Map<String, dynamic>?>> getAllPosts(String sorting) {
    return postCollection.orderBy(sorting, descending: true).snapshots();
  }

  Future<List<Post>> getPosts() async {
    List<Post> res = [];

    await postCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var fullData = doc.data();
        fullData['uid'] = doc.id;
        var currentPost = Post(uid: doc.id, screen: 'timeline', data: fullData);
        res.add(currentPost);
      });
    });
    return Future<List<Post>>.value(res);
  }


  Future<Map<String, dynamic>> getPostByID(String postId) async {
    var post = await postCollection.doc(postId).get();
    return post.data()!;
  }

  Future<String> getUserIdByPostId(String postId) async {
    var post = await postCollection.doc(postId).get();
    return post.data()!['user_uid'];
  }
  /*void visitPost(String postId) async{
    Map<String, dynamic> post = await getPostByID(postId);
    var cat = post['category'];
    var args = data ?? snapshot?.data!.docs[index].data()!;
    if (cat == 'Blog') {
      Navigator.pushNamed(context, viewBlogRoute, arguments: args);
    } else if (cat == 'Workout') {
      Navigator.pushNamed(context, viewWorkoutRoute, arguments: args);
    } else {
      Navigator.pushNamed(context, viewMealPlanRoute, arguments: args);
    }
  }*/

  Stream<QuerySnapshot<Map<String, dynamic>?>> getUserPosts(String uid) {
    final Query<Map<String, dynamic>> userPosts = postCollection
        .where('user_uid', isEqualTo: uid);
    notifyListeners();
    return userPosts.orderBy('createdAt', descending: true).snapshots();
  }

  Future<List<String>> getUserPostsIDs(String uid) async {
    List<String> ids = [];

    await postCollection
        .where('user_uid', isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var currID = doc.id;
        ids.add(currID);
      }
    });
    return ids;
  }

  Future<void> deletePost(String postUid) async {
    postCollection.doc(postUid).delete();
    _commentsManager.deleteComments(postUid);
    notifyListeners();
  }

  Future<bool> checkPostsExists(String postUid) async {
    var tmp = await postCollection.doc(postUid).get();
    return tmp.exists;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(String postId) async {
    return postCollection.doc(postId).get();
  }

  Future<String?> getPostPicture(String postId) async {
    return postCollection
        .doc(postId)
        .get()
        .then((data){
            String? to_ret = data['image_url'];
            return to_ret;
        });
  }

  Future<String?> getPostType(String postId) async{
    return postCollection
        .doc(postId)
        .get()
        .then((data){
          return data['category']; // 'Blog' 'Workout 'Meal Plan'
        });
  }

  //TODO: change location to users or something
  ///get user info from db
  Future<Map<String, dynamic>?> getUserInfo(String userUid) async {
    Map<String, dynamic>? userData;
    await userCollection
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

  //TODO: change location because this isn't post
  Future<Map<String, String?>?> getUserPicAndName(String userId) async {
    String? profilePic;
    String? username;
    await getUserInfo(userId).then((data) {
      profilePic = data!['picture'];
      username = data['name'];
    });
    return {
      'picture': profilePic,
      'name': username,
    };
  }
}

