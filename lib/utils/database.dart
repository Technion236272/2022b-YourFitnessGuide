
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class SearchModel {
  String? name;
  String? uid;
  String? pictureUrl;

  SearchModel(
      {required this.name, required this.uid, required this.pictureUrl});
/*
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(

      name: json['name'],
  pictureUrl: json['picture'],*/

}

class FirebaseDB with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<SearchModel>> getUsers() async {
    List<SearchModel> res = [];

    await _db.collection("users").get().then((querySnapshot) {
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
}
