import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yourfitnessguide/utils/post_manager.dart';
import 'dart:io';

import 'database.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

enum SignUpErrors { Mail_Already_Exists, InvalidEmail, WeakPassword }

class UserModel {
  String? name;
  int? goal;
  int? iWeight;
  int? gWeight;
  int? cWeight;
  int? rating;
  int? following;
  int? followers;
  int saved;
  String? pictureUrl;
  List<String>? savedPosts = [];
  List<String>? imFollowing = [];
  List<String>? followingMe = [];

  UserModel(
      {this.name,
      this.goal,
      this.iWeight,
      this.cWeight,
      this.gWeight,
      this.pictureUrl,
      this.following,
      this.followers,
      this.rating,
      required this.saved,
      this.savedPosts,
      this.imFollowing,
      this.followingMe});
/*
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(

      name: json['name'],
  pictureUrl: json['picture'],*/

}

class AuthRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  UserModel? _userData;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  UserModel? get userData => _userData;

  bool get isAuthenticated => status == Status.Authenticated;

  List<String>? get savedPosts => _userData?.savedPosts;

  List<String>? get following => _userData?.imFollowing;

  List<String>? get followers => _userData?.followingMe;

  Future<Object?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      var res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      var url = await _storage
          .ref('images')
          .child('ProfilePicture.jpg')
          .getDownloadURL();

      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .set({
        'name': 'Undefined Name',
        'picture': url,
        'initial_weight': null,
        'current_weight': null,
        'goal_weight': null,
        'goal': 0,
        'rating': 0,
        'saved': 0,
        'following': 0,
        'followers': 0,
        'saved_posts': [],
        'imFollowing': [],
        'followingMe': []
      });
      _userData = UserModel(
          name: 'Undefined Name',
          pictureUrl: url,
          iWeight: 0,
          cWeight: 0,
          gWeight: 0,
          goal: 0,
          rating: 0,
          saved: 0,
          followers: 0,
          following: 0,
          savedPosts: [],
          imFollowing: [],
          followingMe: []);
      return res;
    } on FirebaseAuthException catch (error) {
      _userData = null;
      print(error);
      _status = Status.Unauthenticated;
      notifyListeners();

      var errorCode = error.code;
      switch (errorCode) {
        case "email-already-in-use":
          return 0;
        case "invalid-email":
          return 1;
        case "weak-password":
          return 2;
        default:
          return null;
      }
    } catch (error) {
      print(error);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _userData = null;
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<int> signInWithFacebook() async {
    final String? token;
    try {
      final facebookLoginResult = await FacebookAuth.i.login();
      token = facebookLoginResult.accessToken!.token;
      final OAuthCredential cred = FacebookAuthProvider.credential(token);
      var res = await _auth.signInWithCredential(cred);
      if (res.additionalUserInfo!.isNewUser) {
        return signUpWithFacebook(true);
      }
      return 1;
    } catch (e) {
      print(e);
      _userData = null;
      _status = Status.Unauthenticated;
      notifyListeners();
      return 0;
    }
  }

  Future<int> signUpWithFacebook(bool redirected) async {
    final String? token;
    try {
      if (!redirected) {
        final facebookLoginResult = await FacebookAuth.i.login();
        token = facebookLoginResult.accessToken!.token;
        final OAuthCredential cred = FacebookAuthProvider.credential(token);
        await _auth.signInWithCredential(cred);
      }

      final data = await FacebookAuth.i.getUserData();

      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .set({
        'name': data['name'],
        'picture': data['picture']['data']['url'],
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
        'rating': 0,
        'saved': 0,
        'following': 0,
        'followers': 0,
        'saved_posts': [],
        'followingMe': [],
        'imFollowing': []
      });

      _userData = UserModel(
          name: data['name'],
          pictureUrl: data['picture']['data']['url'],
          iWeight: 0,
          cWeight: 0,
          gWeight: 0,
          goal: 0,
          rating: 0,
          saved: 0,
          followers: 0,
          following: 0,
          savedPosts: [],
          imFollowing: [],
          followingMe: []);

      if (redirected) {
        return 2;
      }
      return 1;
    } catch (e) {
      _userData = null;
      _status = Status.Unauthenticated;
      notifyListeners();
      return 0;
    }
  }

  Future<int> signInWithGoogle() async {
    try {
      var signin = GoogleSignIn(scopes: ['profile']);
      final googleSignInAccount = await signin.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount?.authentication;
      final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      var res = await _auth.signInWithCredential(cred);
      if (res.additionalUserInfo!.isNewUser) {
        return signUpWithGoogle(true);
      }

      return 1;
    } catch (e) {
      _userData = null;
      _status = Status.Unauthenticated;
      notifyListeners();
      return 0;
    }
  }

  Future<int> signUpWithGoogle(bool redirected) async {
    try {
      if (!redirected) {
        var signin = GoogleSignIn(scopes: ['profile']);
        final googleSignInAccount = await signin.signIn();
        final GoogleSignInAuthentication? googleAuth =
            await googleSignInAccount?.authentication;
        final credit = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
        await _auth.signInWithCredential(credit);
      }

      final name = await _auth.currentUser?.displayName;
      final picture = await _auth.currentUser?.photoURL;

      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .set({
        'name': name,
        'picture': picture,
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
        'rating': 0,
        'saved': 0,
        'following': 0,
        'followers': 0,
        'saved_posts': [],
        'followingMe': [],
        'imFollowing': []
      });
      _userData = UserModel(
          name: name,
          pictureUrl: picture,
          iWeight: 0,
          cWeight: 0,
          gWeight: 0,
          goal: 0,
          rating: 0,
          saved: 0,
          followers: 0,
          following: 0,
          savedPosts: [],
          imFollowing: [],
          followingMe: []);

      if (redirected) return 2;
      return 1;
    } catch (e) {
      _userData = null;
      _status = Status.Unauthenticated;
      notifyListeners();
      return 0;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateSaved() async {
    for (var i = 0; i < savedPosts!.length; i++) {
      var tmp = await PostManager().checkPostsExists(savedPosts![i]);
      if (tmp == false) {
        modifySaved(savedPosts![i], true);
        i--;
      }
    }
  }

  bool? checkAlreadyFollowing(String userid){
    if(userData?.imFollowing == null){
      return false;
    }
    return userData?.imFollowing!.contains(userid);
  }

  Future<void> modifyFollow(String userid, bool delete) async {
    if (delete) {
      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .update({
        'imFollowing': FieldValue.arrayRemove([userid]),
        'following': FieldValue.increment(-1)
      });
      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(userid)
          .update({
        'followingMe': FieldValue.arrayRemove([user!.uid]),
        'followers': FieldValue.increment(-1)
      });
      _userData?.imFollowing?.remove(userid);
      _userData?.following = _userData?.imFollowing!.length;
    } else {
      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .update({
        'imFollowing': FieldValue.arrayUnion([userid]),
        'following': FieldValue.increment(1)
      });
      _userData?.following = (_userData?.following)! + 1;
      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(userid)
          .update({
        'followingMe': FieldValue.arrayUnion([user!.uid]),
        'followers': FieldValue.increment(1)
      });
      _userData?.imFollowing?.add(userid);
      _userData?.following = _userData?.imFollowing!.length;
    }
    notifyListeners();
  }

  Future<void> modifySaved(String postuid, bool delete) async {
    if (delete) {
      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .update({
        'saved_posts': FieldValue.arrayRemove([postuid])
      });
      if (_userData!.savedPosts!.contains(postuid)) {
        _userData?.saved--;
        _userData?.savedPosts?.remove(postuid);
      }
    } else {
      await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .update({
        'saved_posts': FieldValue.arrayUnion([postuid])
      });
      _userData?.saved++;
      _userData?.savedPosts?.add(postuid);
    }
    notifyListeners();
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  String? getCurrUid() {
    return _auth.currentUser?.uid;
  }

  Future deleteUser() async {
    var uid = _auth.currentUser?.uid;
    var ids = await PostManager().getUserPostsIDs(uid!);
    for (int i = 0; i < ids.length; i++) {
      PostManager().deletePost(ids[i]);
    }

    _auth.currentUser?.delete();
    FirebaseDB().deleteUserData(uid);
    _user = null;
    _status = Status.Unauthenticated;
    await unsetUserData();
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> setUserData() async {
    try {
      if (_userData != null) return;
      print(user!.uid);
      var dataDocument = await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .get();
      var savedTmp = List<String>.from(dataDocument.get('saved_posts') as List);
      var followingTmp =
          List<String>.from(dataDocument.get('imFollowing') as List);
      var followersTmp =
          List<String>.from(dataDocument.get('followingMe') as List);
      _userData = UserModel(
          name: dataDocument.get('name'),
          goal: dataDocument.get('goal'),
          iWeight: dataDocument.get('initial_weight'),
          cWeight: dataDocument.get('current_weight'),
          gWeight: dataDocument.get('goal_weight'),
          pictureUrl: dataDocument.get('picture'),
          rating: dataDocument.get('rating'),
          imFollowing: dataDocument.get('imFollowing'),
          followingMe: dataDocument.get('followingMe'),
          saved: savedTmp.length,
          following: followingTmp.length,
          followers: followersTmp.length,
          savedPosts: savedTmp);
      print(savedPosts);
    } catch (_) {
      await Future.delayed(Duration(seconds: 1));

      var dataDocument = await _db
          .collection("versions")
          .doc("v2")
          .collection('users')
          .doc(user!.uid)
          .get();
      var savedTmp = List<String>.from(dataDocument.get('saved_posts') as List);
      var followingTmp =
          List<String>.from(dataDocument.get('imFollowing') as List);
      var followersTmp =
          List<String>.from(dataDocument.get('followingMe') as List);
      _userData = UserModel(
          name: dataDocument.get('name'),
          goal: dataDocument.get('goal'),
          iWeight: dataDocument.get('initial_weight'),
          cWeight: dataDocument.get('current_weight'),
          gWeight: dataDocument.get('goal_weight'),
          pictureUrl: dataDocument.get('picture'),
          rating: dataDocument.get('rating'),
          imFollowing: followingTmp,
          followingMe: followersTmp,
          saved: savedTmp.length,
          following: followingTmp.length,
          followers: followersTmp.length,
          savedPosts: savedTmp);
    }
  }

  Future<void> unsetUserData() async {
    _userData = null;
  }

  Future<void> updateUserData(
      String? newName,
      int? newInitialWeight,
      int? newCurrentWeight,
      int? newGoalWeight,
      int? newGoal,
      File? newPic) async {
    if (newPic != null) {
      await _storage.ref('images').child(_user!.uid).putFile(newPic);
      _userData?.pictureUrl =
          await _storage.ref('images').child(_user!.uid).getDownloadURL();
    }
    await _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(user!.uid)
        .update({
      'name': newName,
      'initial_weight': newInitialWeight,
      'current_weight': newCurrentWeight,
      'goal_weight': newGoalWeight,
      'goal': newGoal,
      'picture': userData?.pictureUrl
    });
    _userData?.name = newName;
    _userData?.iWeight = newInitialWeight;
    _userData?.cWeight = newCurrentWeight;
    _userData?.gWeight = newGoalWeight;
    _userData?.goal = newGoal;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
      await unsetUserData();
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
      await setUserData();
    }
    notifyListeners();
  }
}
