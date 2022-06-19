import 'package:yourfitnessguide/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:yourfitnessguide/managers/post_manager.dart';

class NotificationsManager with ChangeNotifier {
  addNotification(String postId, String type, String commentData) async {
    /// You get a notification on every interaction.
    /// If you want to change to only latest interaction on a certain post you
    /// should do the following:
    /// change the .add({...} to .doc(postId).set({...})
    /// Explanation to the change:
    /// Since we are going to be updating the same document referenced by the:
    /// 1. owner id
    /// 2. the post id
    /// this is going to be overwritten everytime a like is made to that post
    String ownerId = await PostManager().getUserIdByPostId(postId);
    bool isNotPostOwner = getCurrUid() != ownerId;
    if (isNotPostOwner) {
      notificationsCollection
          .doc(ownerId)
          .collection("feedItems")
          .add({
            "type": type, ///'upvote', 'downvote', 'comment, 'follow'
            "userId": getCurrUid(),
            "postId": postId,
            "timestamp": timestamp,
            "commentData" : commentData,
          });
    }
    notifyListeners();
  }

  removeNotification(String ownerId, String postId, String type) async {
    bool isNotPostOwner = getCurrUid() != ownerId;
    if (isNotPostOwner) {
      var query = await notificationsCollection
          .doc(ownerId)
          .collection("feedItems")
          .where('userId', isEqualTo: getCurrUid())
          .where('postId', isEqualTo: postId)
          .where('type', isEqualTo: type)
          .get();
      for(var doc in query.docs){
        doc.reference.delete();
      }
      notifyListeners();
    }
  }

  /// Owner is the user being followed
  addFollowNotification(String ownerId){
    notificationsCollection
        .doc(ownerId)
        .collection("feedItems")
        .add({
      "type": 'follow',
      "userId": getCurrUid(),
      "postId": '',
      "timestamp": timestamp,
      "commentData": ''
    });
  }

  removeFollowNotification(String ownerId) async {
    var query = await notificationsCollection
        .doc(ownerId)
        .collection("feedItems")
        .where('userId', isEqualTo: getCurrUid())
        .where('type', isEqualTo: 'follow')
        .get();
    for(var doc in query.docs){
      doc.reference.delete();
    }
    notifyListeners();
  }
}