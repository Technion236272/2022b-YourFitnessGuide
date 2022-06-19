import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/utils/database.dart';

enum Status { uninitialized, authenticated, authenticating, unauthenticated }

enum SignUpErrors { mailAlreadyExists, invalidEmail, weakPassword }

class UserModel {
  String? name;
  int? goal;
  int? iWeight;
  int? gWeight;
  int? cWeight;
  int rating;
  int? following;
  int? followers;
  int saved;
  String? pictureUrl;
  List<String>? savedPosts = [];
  List<String>? imFollowing = [];
  List<String>? followingMe = [];
  List<String>? likes = [];//Map<String, int>? likes = {}; ///From post id to -> -1: Downvoted, 1: Upvoted
  Map<String, bool>? privacySettings = {};

  UserModel(
      {this.name,
      this.goal,
      this.iWeight,
      this.cWeight,
      this.gWeight,
      this.pictureUrl,
      this.following,
      this.followers,
      required this.rating,
      required this.saved,
      this.savedPosts,
      this.imFollowing,
      this.followingMe,
      this.privacySettings});
/*
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(

      name: json['name'],
  pictureUrl: json['picture'],*/

}

class AuthRepository with ChangeNotifier {
  User? _user;
  Status _status = Status.uninitialized;
  UserModel? _userData;

  AuthRepository.instance() {
    firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    _user = firebaseAuth.currentUser;
    _onAuthStateChanged(_user);
  }


  /// Getters
  Status get status => _status;
  User? get user => _user;
  UserModel? get userData => _userData;
  bool get isAuthenticated => status == Status.authenticated;
  List<String>? get savedPosts => _userData?.savedPosts;
  String get uid => user!.uid;
  List<String>? get followingList => _userData?.imFollowing;
  List<String>? get followersList => _userData?.followingMe;
  Map<String, bool>? get privacySettings => _userData?.privacySettings;
  String? get pictureUrl => _userData?.pictureUrl;
  String? get name => _userData?.name;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.unauthenticated;
      await unsetUserData();
    } else {
      _user = firebaseUser;
      _status = Status.authenticated;
      await setUserData();
    }
    notifyListeners();
  }

  /// Sign in, Sign up, Sign out + forgot password
  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _userData = null;
      _status = Status.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<Object?> signUp(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      var res = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      var url = await storage
          .ref('images')
          .child('ProfilePicture.jpg')
          .getDownloadURL();

      await userCollection
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
        'followingMe': [],
        'privacySettings': {}
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
          followingMe: [],
          privacySettings: {});
      return res;
    } on FirebaseAuthException catch (error) {
      _userData = null;
      print(error);
      _status = Status.unauthenticated;
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
      _status = Status.unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<int> signInWithFacebook() async {
    final String? token;
    try {
      final facebookLoginResult = await FacebookAuth.i.login();
      token = facebookLoginResult.accessToken!.token;
      final OAuthCredential cred = FacebookAuthProvider.credential(token);
      var res = await firebaseAuth.signInWithCredential(cred);
      if (res.additionalUserInfo!.isNewUser) {
        return signUpWithFacebook(true);
      }
      return 1;
    } catch (e) {
      print(e);
      _userData = null;
      _status = Status.unauthenticated;
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
        await firebaseAuth.signInWithCredential(cred);
      }

      final data = await FacebookAuth.i.getUserData();

      await userCollection
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
        'imFollowing': [],
        'privacySettings': {}
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
          followingMe: [],
          privacySettings: {});

      if (redirected) {
        return 2;
      }
      return 1;
    } catch (e) {
      _userData = null;
      _status = Status.unauthenticated;
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
      var res = await firebaseAuth.signInWithCredential(cred);
      if (res.additionalUserInfo!.isNewUser) {
        return signUpWithGoogle(true);
      }

      return 1;
    } catch (e) {
      _userData = null;
      _status = Status.unauthenticated;
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
        await firebaseAuth.signInWithCredential(credit);
      }

      final name = firebaseAuth.currentUser?.displayName;
      final picture = firebaseAuth.currentUser?.photoURL;

      await userCollection
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
        'imFollowing': [],
        'privacySettings': {}
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
          followingMe: [],
      privacySettings: {});

      if (redirected) return 2;
      return 1;
    } catch (e) {
      _userData = null;
      _status = Status.unauthenticated;
      notifyListeners();
      return 0;
    }
  }

  Future signOut() async {
    firebaseAuth.signOut();
    _status = Status.unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<bool> resetPassword(String email) async {
    try {
      firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (_) {
      return false;
    }
  }


  /// Save posts functions
  Future<void> updateSaved() async {
    for (var i = 0; i < savedPosts!.length; i++) {
      var tmp = await PostManager().checkPostsExists(savedPosts![i]);
      if (tmp == false) {
        modifySaved(savedPosts![i], true);
        i--;
      }
    }
  }

  Future<void> modifySaved(String postuid, bool delete) async {
    if (delete) {
      await userCollection
          .doc(user!.uid)
          .update({
        'saved_posts': FieldValue.arrayRemove([postuid])
      });
      if (_userData!.savedPosts!.contains(postuid)) {
        _userData?.saved--;
        _userData?.savedPosts?.remove(postuid);
      }
    } else {
      await userCollection
          .doc(user!.uid)
          .update({
        'saved_posts': FieldValue.arrayUnion([postuid])
      });
      _userData?.saved++;
      _userData?.savedPosts?.add(postuid);
    }
    notifyListeners();
  }


  /// Follow users functions
  bool? checkImAlreadyFollowing(String userid) {
    if (userData?.imFollowing == null) {
      return false;
    }
    return userData?.imFollowing!.contains(userid);
  }

  /// Modifies vote, whether its upvotes or downvotes.
  Future<void> modifyVote(String postId, String postOwnerId, String voteType, bool val) async {
    //print("Modifying vote WAIT");
    if(val) {
      await postCollection
          .doc(postId)
          .update({voteType: FieldValue.arrayUnion([user!.uid])});
    }
    else{
      await postCollection
          .doc(postId)
          .update({voteType: FieldValue.arrayRemove([user!.uid])});
    }
    notifyListeners();
    if((val == true && voteType == 'upvotes') || (val == false && voteType == 'downvotes')){
      await postCollection
          .doc(postId)
          .update({'rating': FieldValue.increment(1)});
      await userCollection
          .doc(postOwnerId)
          .update({'rating': FieldValue.increment(1)});
      //_userData?.rating += 1;
    }
    else{
      await postCollection
          .doc(postId)
          .update({'rating': FieldValue.increment(-1)});
      await userCollection
          .doc(postOwnerId)
          .update({'rating': FieldValue.increment(-1)});
      //_userData?.rating += -1;
    }
    notifyListeners();
    notifyListeners();
  }

  Future<void> modifyFollow(String userid, bool delete) async {
    if (delete) {
      await userCollection
          .doc(user!.uid)
          .update({
        'imFollowing': FieldValue.arrayRemove([userid]),
        'following': FieldValue.increment(-1)
      });
      await userCollection
          .doc(userid)
          .update({
        'followingMe': FieldValue.arrayRemove([user!.uid]),
        'followers': FieldValue.increment(-1)
      });
      _userData?.imFollowing?.remove(userid);
      _userData?.following = _userData?.imFollowing!.length;
    } else {
      await userCollection
          .doc(user!.uid)
          .update({
        'imFollowing': FieldValue.arrayUnion([userid]),
        'following': FieldValue.increment(1)
      });
      _userData?.following = (_userData?.following)! + 1;
      await userCollection
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

  Future<void> updateFollow() async {
    if (_userData == null) {
      return;
    }
    for (var i = 0; i < _userData!.imFollowing!.length; i++) {
      var tmp = await FirebaseDB().checkUserExists(_userData!.imFollowing![i]);
      if (tmp == false) {
        removeDeletedFollowing(_userData!.imFollowing![i]);
        i--;
      }
    }

    for (var i = 0; i < _userData!.followingMe!.length; i++) {
      var tmp = await FirebaseDB().checkUserExists(_userData!.followingMe![i]);
      if (tmp == false) {
        removeDeletedFollowed(_userData!.followingMe![i]);
        i--;
      }
    }
  }

  Future<void> removeDeletedFollowing(String userid) async {
    _userData?.imFollowing?.remove(userid);
    _userData?.following = _userData?.imFollowing!.length;

    await userCollection
        .doc(user!.uid)
        .update({
      'imFollowing': FieldValue.arrayRemove([userid]),
      'following': _userData?.following
    });

    notifyListeners();
  }

  Future<void> removeDeletedFollowed(String userid) async {
    _userData?.followingMe?.remove(userid);
    _userData?.followers = _userData?.followingMe!.length;
    await userCollection
        .doc(user!.uid)
        .update({
      'followingMe': FieldValue.arrayRemove([userid]),
      'followers': _userData?.followers
    });

    notifyListeners();
  }

  Future<List<SearchUserModel>> getFollowing() async {
    List<SearchUserModel> res = [];
    await userCollection
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (checkImAlreadyFollowing(doc.id)!) {
          var currentUser = SearchUserModel(
              name: doc.get('name'),
              uid: doc.id.toString(),
              pictureUrl: doc.get('picture'));
          res.add(currentUser);
        }
      });
    });
    print(res);
    return Future<List<SearchUserModel>>.value(res);
  }

  Future<List<SearchUserModel>> getFollowers() async {
    List<SearchUserModel> res = [];

    await userCollection
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var currentDocument = doc.get('name');
        var currentUser = SearchUserModel(
            name: doc.get('name'),
            uid: doc.id.toString(),
            pictureUrl: doc.get('picture'));
        res.add(currentUser);
      });
    });
    return Future<List<SearchUserModel>>.value(res);
  }


  /// I think for search?
  Future<List<SearchUserModel>> getUsers() async {
    List<SearchUserModel> res = [];

    await userCollection
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var currentDocument = doc.get('name');
        var currentUser = SearchUserModel(
            name: doc.get('name'),
            uid: doc.id.toString(),
            pictureUrl: doc.get('picture'));
        res.add(currentUser);
      });
    });
    return Future<List<SearchUserModel>>.value(res);
  }



  Future deleteUser() async {
    var uid = firebaseAuth.currentUser?.uid;
    var ids = await PostManager().getUserPostsIDs(uid!);
    for (int i = 0; i < ids.length; i++) {
      PostManager().deletePost(ids[i]);
    }

    firebaseAuth.currentUser?.delete();
    FirebaseDB().deleteUserData(uid);
    _user = null;
    _status = Status.unauthenticated;
    await unsetUserData();
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  /// User data functions
  Future<void> setUserData() async {
    try {
      if (_userData != null) return;
      //updateSaved();
      var dataDocument = await userCollection
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
          savedPosts: savedTmp,
      privacySettings: Map<String, bool>.from(dataDocument.get('privacySettings')));
      print(savedPosts);
    } catch (_) {
      await Future.delayed(const Duration(seconds: 1));

      var dataDocument = await userCollection
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
          savedPosts: savedTmp,
          privacySettings: Map<String, bool>.from(dataDocument.get('privacySettings')));
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
      File? newPic,
      Map<String, bool> privacySettings) async {
    if (newPic != null) {
      await storage.ref('images').child(_user!.uid).putFile(newPic);
      _userData?.pictureUrl = await storage.ref('images').child(_user!.uid).getDownloadURL();
    }
    await userCollection
        .doc(user!.uid)
        .update({
      'name': newName,
      'initial_weight': newInitialWeight,
      'current_weight': newCurrentWeight,
      'goal_weight': newGoalWeight,
      'goal': newGoal,
      'picture': userData?.pictureUrl,
      'privacySettings': privacySettings
    });
    _userData?.name = newName;
    _userData?.iWeight = newInitialWeight;
    _userData?.cWeight = newCurrentWeight;
    _userData?.gWeight = newGoalWeight;
    _userData?.goal = newGoal;
    notifyListeners();
  }
}


