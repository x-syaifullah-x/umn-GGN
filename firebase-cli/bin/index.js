import { firestore } from "firebase-functions";
import { initializeApp, firestore as _firestore, messaging } from "firebase-admin";
initializeApp();

export const onCreateFollower = firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    console.log("Follower Created", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // 1) Create followed users posts ref
    const followedUserPostsRef = _firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    // 2) Create following user's timeline ref
    const timelinePostsRef = _firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    // 3) Get followed users posts
    const querySnapshot = await followedUserPostsRef.get();

    // 4) Add each user post to following user's timeline
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });
  });

export const onDeleteFollower = firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower Deleted", snapshot.id);

    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = _firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

export const onCreatePost = firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = _firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Add new post to each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      _firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });


export const onUpdatePost = firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = _firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Update each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      _firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });

export const onDeletePost = firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    // 1) Get all the followers of the user who made the post
    const userFollowersRef = _firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    // 2) Delete each post in each follower's timeline
    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      _firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });

export const onCreateActivityFeedItem = firestore
  .document("/feed/{userId}/feedItems/{activityFeedItem}")
  .onCreate(async (snapshot, context) => {
    console.log("Activity Feed Item Created", snapshot.data());

    // 1) Get user connected to the feed
    const userId = context.params.userId;

    const userRef = _firestore().doc(`users/${userId}`);
    const doc = await userRef.get();
    console.log("Activity Feed Item Created doc", doc.data());

    // 2) Once we have user, check if they have a notification token; send notification, if they have a token
    const androidNotificationToken = doc.data().androidNotificationToken;
    const createdActivityFeedItem = snapshot.data();
    if (androidNotificationToken) {
      sendNotification(androidNotificationToken, createdActivityFeedItem);
    } else {
      console.log("No token for user, cannot send notification");
    }

    function sendNotification(androidNotificationToken, activityFeedItem) {
      let body;

      // 3) switch body value based off of notification type
      switch (activityFeedItem.type) {
        case "comment":
          body = `${activityFeedItem.username} Commented on your post: ${activityFeedItem.commentData
            }`;
          break;
        case "like":
          body = `${activityFeedItem.username} liked your post`;
          break;
        case "follow":
          body = `${activityFeedItem.username} started following you`;
          break;
        case "message":
          body = `You have a message from ${activityFeedItem.username}: ${activityFeedItem.contentMessage
            }`;
          break;
        default:
          break;
      }

      // 4) Create message for push notification
      const message = {
        notification: { body },
        token: androidNotificationToken,
        data: { recipient: userId, }
      };

      // 5) Send message with admin.messaging()
      messaging()
        .send(message)
        .then(response => {
          // Response is a message ID string
          console.log("Successfully sent message", response);
        })
        .catch(error => {
          console.log("Error sending message", error);
        });
    }
  });
