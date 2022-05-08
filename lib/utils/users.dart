import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }
enum SignUpErrors { Mail_Already_Exists, InvalidEmail, WeakPassword }

class UserModel {
  final String? name;
  final int? goal;
  final int? IWeight;
  final int? GWeight;
  final int? CWeight;
  final String? pictureUrl;

  const UserModel({this.name, this.goal, this.IWeight, this.CWeight,this.GWeight,  this.pictureUrl});
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

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  Future<Object?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      var res = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print('nino mata');
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': 'Undefined Name',
        'picture': null,
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
      });
      return res;
    } on FirebaseAuthException catch (error) {
      print(error);
      _status = Status.Unauthenticated;
      notifyListeners();

      var errorCode = error.code;
      switch(errorCode){
        case "email-already-in-use":
          return 0;
        case "invalid-email":
          return 1;
        case "weak-password":
          return 2;
        default:
          return null;
      }
    }
    catch(error){
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
      await _auth.signInWithCredential(cred);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithFacebook() async {
    final String? token;
    try {
      final facebookLoginResult = await FacebookAuth.i.login();
      token = facebookLoginResult.accessToken!.token;
      final OAuthCredential cred = FacebookAuthProvider.credential(token);
      await _auth.signInWithCredential(cred);
      final userData = await FacebookAuth.i.getUserData();
      print('aloalo');
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': userData['name'],
        'picture': userData['picture']['data']['url'],
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

  Future<bool> signInWithGoogle() async {
    try {
      var signin = GoogleSignIn(scopes: ['email', 'profile']);
      final googleSignInAccount = await signin.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleSignInAccount?.authentication;
      final credit = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      await _auth.signInWithCredential(credit);

      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithGoogle() async {
    try {
      var signin = GoogleSignIn(scopes: ['email', 'profile']);
      final googleSignInAccount = await signin.signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleSignInAccount?.authentication;
      final credit = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      await _auth.signInWithCredential(credit);
      /*await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': userData['name'],
        'picture': userData['picture']['data']['url'],
        'initial_weight': 0,
        'current_weight': 0,
        'goal_weight': 0,
        'goal': 0,
      });*/
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

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
}
