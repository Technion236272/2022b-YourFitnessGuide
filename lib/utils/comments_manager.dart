import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/services/file_upload_service.dart';
import 'package:yourfitnessguide/utils/widgets.dart';

class CommentsManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _commentsCollection =
      _db.collection("versions").doc("v2").collection("comments");

  final CollectionReference<Map<String, dynamic>> _postCollection =
  _db.collection("versions").doc("v2").collection("posts");
  CollectionReference<Map<String, dynamic>> get commentsRef =>
      _commentsCollection;
  final FileUploadService _fileUploadService = FileUploadService();

  addComment(String postId, String userId, String comment) {
    FieldValue timeStamp = FieldValue.serverTimestamp();
    _commentsCollection.doc(postId).collection("comments").add({
      "comment": comment,
      "timestamp": timeStamp,
      "userId": userId,
    });
  }

  Future<void> deleteUserComment(String postUid, String userId) async {
    var query = await _commentsCollection
        .doc(postUid)
        .collection('comments')
        .where('userId', isEqualTo: userId).get();
    for (var doc in query.docs) {
      doc.reference.delete();
    }
    notifyListeners();
  }
  Future<void> deleteComments(String postUid) async {
    var query = await _commentsCollection
        .doc(postUid)
        .collection('comments')
        .get();
    for (var doc in query.docs) {
        doc.reference.delete();
    }
    notifyListeners();
  }




  Stream<QuerySnapshot<Map<String, dynamic>?>> getComments(String postId) {
    return _commentsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> addCommentsNum(String postid) async {

    await _db
        .collection("versions")
        .doc("v2")
        .collection('posts')
        .doc(postid)
        .update({
      'commentsNum': FieldValue.increment(1)
    });

    notifyListeners();
  }
  Future<void> updateCommentsNum(String postid) async {
    int length=0;
    var query = await _commentsCollection
        .doc(postid)
        .collection('comments')
        .get();
    for (var doc in query.docs) {
      {
       length++;

      };
    }
    //print(length);
    await _db
        .collection("versions")
        .doc("v2")
        .collection('posts')
        .doc(postid)
        .update({
      'commentsNum': length
    });

    notifyListeners();
  }
}
