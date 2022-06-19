import 'package:yourfitnessguide/utils/globals.dart';

/*
class NotificationsManager {
  addUpvoteToNotification(String ownerId, String postId) {
    /// Since we are going to be updating the same document referenced by the:
    /// 1. owner id
    /// 2. the post id
    /// this is going to be overwritten everytime a like is made to that post
    /// TODO: If we want to change it, it is easy; simply:
    /// change the .doc(postId).set({...}) to .add({...})
    bool isNotPostOwner = getCurrUid() != ownerId;
    if (isNotPostOwner) {
      notificationsCollection
          .doc(ownerId)
          .collection("feedItems")
          .add({
        "type": "like",
        "userId": widget.user.uid,
        "postId": postId,
        "timestamp": timestamp,
      });
    }
  }

  removeUpvoteToNotification(String ownerId, String postId) {
    bool isNotPostOwner = widget.user.uid != ownerId;
    if (isNotPostOwner) {
      notificationsCollection
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }
}

 */