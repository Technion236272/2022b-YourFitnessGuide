
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:yourfitnessguide/utils/users.dart';

class SearchModel {
  String? name;
  String? uid;
  String? pictureUrl;
  late Image picture;

  SearchModel(
      {required this.name, required this.uid, required this.pictureUrl}){
    picture = Image.network(pictureUrl!);
  }
/*
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(

      name: json['name'],
  pictureUrl: json['picture'],*/

}

class FirebaseDB with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<SearchModel>> getUsers() async {
    List<SearchModel> res = [];

    await _db.collection("versions").doc("v1").collection("users").get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var currentDocument = doc.get('name');
        var currentUser = SearchModel(
            name: doc.get('name'),
            uid: doc.id.toString(),
            pictureUrl: doc.get('picture'));
        res.add(currentUser);
      });
    });
    return Future<List<SearchModel>>.value(res);
  }

  Future<void> deleteUserData(String uid) async {
    await _db.collection("versions").doc("v1").collection('users').doc(uid).delete();

  }

  ///get user info from db
  Future<Map<String, dynamic>?> getUserInfo(String userUid) async {
    Map<String, dynamic>? userData;
    await _db.collection("versions").doc("v1").collection("users")
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

  Future<UserModel?> getUserModel(String userUid) async {
    UserModel? userData;
    await _db.collection("versions").doc("v1").collection("users")
        .doc(userUid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> dataDocument) {
      if (dataDocument.exists) {
        userData = UserModel(
            name: dataDocument.get('name'),
            goal: dataDocument.get('goal'),
            iWeight: dataDocument.get('initial_weight'),
            cWeight: dataDocument.get('current_weight'),
            gWeight: dataDocument.get('goal_weight'),
            pictureUrl: dataDocument.get('picture'),
            following: dataDocument.get('following'),
            followers: dataDocument.get('followers'),
            rating: dataDocument.get('rating'),
            saved: dataDocument.get('saved'));
      } else {
        userData = null;
      }
    });
    return userData;
  }
}
