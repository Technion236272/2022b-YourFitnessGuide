import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yourfitnessguide/Screens/editProfileScreen.dart';
import 'dart:io';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

enum SignUpErrors { Mail_Already_Exists, InvalidEmail, WeakPassword }

class UserModel {
  String? name;
  int? goal;
  int? iWeight;
  int? gWeight;
  int? cWeight;
  String? pictureUrl;

  UserModel(
      {this.name,
      this.goal,
      this.iWeight,
      this.cWeight,
      this.gWeight,
      this.pictureUrl});
/*
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(

      name: json['name'],
  pictureUrl: json['picture'],*/

}

class SearchModel {
  String? name;
  String? uid;
  String? pictureUrl;

  SearchModel(
      {required this.name,
        required this.uid,
        required this.pictureUrl});
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

  Future<Object?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      var res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': 'Undefined Name',
        'picture': null,
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
        'rating': 4,
        'saved': 3,
        'following': 2,
        'followers': 1
      });
      return res;
    } on FirebaseAuthException catch (error) {
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

  Future<Set<SearchModel>> getUsers() async{
    Set<SearchModel> res = {};

    await _db.collection("users").get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var currentDocument = doc.get('name');
        print(currentDocument);
        var currentUser = SearchModel(name: doc.get('name'), uid: doc.id.toString(),pictureUrl: doc.get('picture'));
        res.add(currentUser);
      });
    });
    return Future<Set<SearchModel>>.value(res);
  }


  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    final String? token;
    try {
      final facebookLoginResult = await FacebookAuth.i.login();
      token = facebookLoginResult.accessToken!.token;
      final OAuthCredential cred = FacebookAuthProvider.credential(token);
      var res = await _auth.signInWithCredential(cred);
      if (res.additionalUserInfo!.isNewUser) {
        signUpWithFacebook(true);
      }
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithFacebook(bool redirected) async {
    final String? token;
    try {
      if (!redirected) {
        final facebookLoginResult = await FacebookAuth.i.login();
        token = facebookLoginResult.accessToken!.token;
        final OAuthCredential cred = FacebookAuthProvider.credential(token);
        await _auth.signInWithCredential(cred);
      }

      final _userData = await FacebookAuth.i.getUserData();

      await _db.collection('users').doc(user!.uid).set({
        'name': _userData['name'],
        'picture': _userData['picture']['data']['url'],
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
        'rating': 4,
        'saved': 3,
        'following': 2,
        'followers': 1
      });
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      var signin = GoogleSignIn(scopes: ['profile']);
      final googleSignInAccount = await signin.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount?.authentication;
      final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      var res = await _auth.signInWithCredential(cred);
      if (res.additionalUserInfo!.isNewUser) {
        signUpWithGoogle(true);
      }

      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithGoogle(bool redirected) async {
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

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': name,
        'picture': picture,
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
      });
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
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

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> setUserData() async {
    try {
      var dataDocument = await _db.collection('users').doc(user!.uid).get();
      _userData = UserModel(
          name: dataDocument.get('name'),
          goal: dataDocument.get('goal'),
          iWeight: dataDocument.get('initial_weight'),
          cWeight: dataDocument.get('current_weight'),
          gWeight: dataDocument.get('goal_weight'),
          pictureUrl: dataDocument.get('picture'));
    } catch (_) {
      await Future.delayed(Duration(seconds: 3));
      var dataDocument = await _db.collection('users').doc(user!.uid).get();
      _userData = UserModel(
          name: dataDocument.get('name'),
          goal: dataDocument.get('goal'),
          iWeight: dataDocument.get('initial_weight'),
          cWeight: dataDocument.get('current_weight'),
          gWeight: dataDocument.get('goal_weight'),
          pictureUrl: dataDocument.get('picture'));
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
    await _db.collection('users').doc(user!.uid).update({
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
