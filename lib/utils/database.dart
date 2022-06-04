import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:yourfitnessguide/utils/users.dart';

class SearchUserModel {
  String? name;
  String? uid;
  String? pictureUrl;
  int? rating;
  late Image picture;

  SearchUserModel(
      {required this.name, required this.uid, required this.pictureUrl, this.rating}) {
    picture = Image.network(pictureUrl!);
  }
}

class FirebaseDB with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var user;

  Future<List<SearchUserModel>> getUsers() async {
    List<SearchUserModel> res = [];

    await _db
        .collection("versions")
        .doc("v2")
        .collection("users")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var currentDocument = doc.get('name');
        var currentUser = SearchUserModel(
            name: doc.get('name'),
            uid: doc.id.toString(),
            rating: doc.get('rating'),
            pictureUrl: doc.get('picture'));
        res.add(currentUser);
      });
    });
    return Future<List<SearchUserModel>>.value(res);
  }

  /*
  int? getFollowingNumber(String userid)  {
    int? following = 0;
    _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(userid)
        .get()
        .then((doc) {
      var followersList = List<String>.from(doc.get('imFollowing') as List);
      following = followersList.length;

    });
    return following;

  }

  int? getFollowersNumber(String userid){
    int? followers = -2;
    _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(userid)
        .get()
        .then((doc) {
      var followersList = List<String>.from(doc.get('followingMe') as List);
      followers = followersList.length;
      print('nppr' + followersList.length.toString());
    });

    return followers;
  }*/

  Future<void> deleteUserData(String uid) async {
    await _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(uid)
        .delete();
  }

  bool checkFollowing(String uid1, String uid2) {
    var followingList = [];
    _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(uid1)
        .get()
        .then((doc) {
      var followingList = List<String>.from(doc.get('imFollowing') as List);
    });
    if (followingList.contains(uid2))
      return true;
    else
      return false;
  }

  Future<bool> checkUserExists(String userUid) async {
    var tmp = await _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(userUid)
        .get();
    return tmp.exists;
  }

  ///get user info from db
  Future<Map<String, dynamic>?> getUserInfo(String userUid) async {
    Map<String, dynamic>? userData;
    await _db
        .collection("versions")
        .doc("v2")
        .collection("users")
        .doc(userUid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        userData = doc.data();
      } else {
        userData = null;
      }
    });
    return userData;
  }

  Future<void> updateFollow(UserModel _userData, String currid) async {
    for (var i = 0; i < _userData.imFollowing!.length; i++) {
      var tmp = await FirebaseDB().checkUserExists(_userData.imFollowing![i]);
      if (tmp == false) {
        removeDeletedFollowing(_userData, currid, _userData.imFollowing![i]);
        i--;
      }
    }

    for (var i = 0; i < _userData.followingMe!.length; i++) {
      var tmp = await FirebaseDB().checkUserExists(_userData.followingMe![i]);
      if (tmp == false) {
        removeDeletedFollowed(_userData, currid, _userData.followingMe![i]);
        i--;
      }
    }
  }

  Future<void> removeDeletedFollowing(
      UserModel _userData, String curruid, String userid) async {
    _userData.imFollowing?.remove(userid);
    _userData.following = _userData.imFollowing!.length;

    await _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(curruid)
        .update({
      'imFollowing': FieldValue.arrayRemove([userid]),
      'following': _userData.following
    });

    notifyListeners();
  }

  Future<void> removeDeletedFollowed(
      UserModel _userData, String curruid, String userid) async {
    _userData.followingMe?.remove(userid);
    _userData.followers = _userData.followingMe!.length;
    await _db
        .collection("versions")
        .doc("v2")
        .collection('users')
        .doc(curruid)
        .update({
      'followingMe': FieldValue.arrayRemove([userid]),
      'followers': _userData.followers
    });

    notifyListeners();
  }

  Future<UserModel?> getUserModel(String userUid) async {
    UserModel? userData;
    await _db
        .collection("versions")
        .doc("v2")
        .collection("users")
        .doc(userUid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> dataDocument) {
      if (dataDocument.exists) {
        var savedTmp =
            List<String>.from(dataDocument.get('saved_posts') as List);
        var followingTmp =
            List<String>.from(dataDocument.get('imFollowing') as List);
        var followersTmp =
            List<String>.from(dataDocument.get('followingMe') as List);

        userData = UserModel(
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
      } else {
        userData = null;
      }
    });
    return userData;
  }
}
