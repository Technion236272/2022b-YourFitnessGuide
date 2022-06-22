import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/utils/globals.dart';
import 'package:yourfitnessguide/managers/notifications_manager.dart';

class CommentsManager with ChangeNotifier {

  /// Adds comment made by userId to postId
  addComment(String postId, String comment) {
    commentsCollection
        .doc(postId)
        .collection("comments")
        .add({
          "comment": comment,
          "timestamp": timestamp,
          "userId": getCurrUid()!,
        });
    incrementCommentsNum(postId);

    NotificationsManager().addNotification(postId, 'comment', comment);
  }

  /// Deletes all comments of user
  Future<void> deleteUserComments(String postId, String userId) async {
    var query = await commentsCollection
        .doc(postId)
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in query.docs) {
      doc.reference.delete();
    }
    notifyListeners();
  }

  Future<void> deleteCommentById(String postId, String commentId) async {
    var query = await commentsCollection
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
    notifyListeners();
  }
  /// Deletes all comments of post
  Future<void> deleteComments(String postId) async {
    var query = await commentsCollection
        .doc(postId)
        .collection('comments')
        .get();
    for (var doc in query.docs) {
        doc.reference.delete();
    }
    notifyListeners();
  }

  /// Returns all comments of post
  Stream<QuerySnapshot<Map<String, dynamic>?>> getComments(String postId) {
    return commentsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Increments comments number of post
  Future<void> incrementCommentsNum(String postId) async {
    await postCollection
        .doc(postId)
        .update({'commentsNum': FieldValue.increment(1)});
    notifyListeners();
  }

  /// Updates comments number of post
  Future<void> updateCommentsNum(String postId) async {
    int length=0;
    var query = await commentsCollection
        .doc(postId)
        .collection('comments')
        .get();
    for (var _ in query.docs) {
       length++;
    }
    await postCollection
        .doc(postId)
        .update({'commentsNum': length});
    notifyListeners();
  }
}
