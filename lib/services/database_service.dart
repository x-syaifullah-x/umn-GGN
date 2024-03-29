import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({
    this.uid,
  });

  // Collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // update userdata
  // Future updateUserData(String fullName, String email, String password) async {
  //   return await userCollection.doc(uid).set({
  //     'fullName': fullName,
  //     'email': email,
  //     'password': password,
  //     'groups': [],
  //     'profilePic': ''
  //   });
  // }

  // create group
  Future createLesson(String? userName, String lessonName) async {
    DocumentReference groupDocRef = await lessonsCollection.add({
      'lessonName': lessonName,
      'lessonIcon': '',
      'admin': userName,
      'members': [],
      'lessonId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion(['${globalUserId}_${userName!}']),
      'lessonId': groupDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(globalUserId);
    return await userDocRef.update({
      'lessons': FieldValue.arrayUnion([groupDocRef.id + '_' + lessonName])
    });
  }

  // create group
  Future createGroup(String? userName, String groupName) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'members': [],
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion(['${globalUserId}_${userName!}']),
      'groupId': groupDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(globalUserId);
    return await userDocRef.update({
      'groups': FieldValue.arrayUnion([groupDocRef.id + '_' + groupName])
    });
  }

  // toggling the user group join
  Future togglingLessonJoin(
      String lessonId, String groupName, String lessonName) async {
    final userDocRef = userCollection.doc(uid);
    final userDocSnapshot = await userDocRef.get();
    late List<dynamic> lessons;
    try {
      lessons = await userDocSnapshot['lessons'];
    } catch (e) {
      lessons = [];
    }

    DocumentReference groupDocRef = lessonsCollection.doc(lessonId);

    if (lessons.contains(lessonId + '_' + groupName)) {
      await userDocRef.update({
        'lessons': FieldValue.arrayRemove([lessonId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([uid! + '_' + lessonName])
      });
    } else {
      await userDocRef.update({
        'lessons': FieldValue.arrayUnion([lessonId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion([uid! + '_' + lessonName])
      });
    }
  }

  // toggling the user group join
  Future togglingGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.doc(groupId);

    List<dynamic> groups = await userDocSnapshot['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('hey');
      await userDocRef.update({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([uid! + '_' + userName])
      });
    } else {
      //print('nay');
      await userDocRef.update({
        'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion([uid! + '_' + userName])
      });
    }
  }

  // has user joined the group
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> groups = await userDocSnapshot['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('he');
      return true;
    } else {
      //print('ne');
      return false;
    }
  }

  Future<bool> isUserJoinedLesson(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> groups = await userDocSnapshot['lessons'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('he');
      return true;
    } else {
      //print('ne');
      return false;
    }
  }

  // get user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUser() async {
    return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  }

  // send message
  lessonSendMessage(String? groupId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('lessons')
        .doc(groupId)
        .collection('messages')
        .add(chatMessageData);
    FirebaseFirestore.instance.collection('lessons').doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  // send message
  sendMessage(String? groupId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(chatMessageData);
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  // get chats of a particular group
  getChatsLesson(String? groupId) async {
    return FirebaseFirestore.instance
        .collection('lessons')
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // get chats of a particular group
  getChats(String? groupId) async {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // search groups
  searchByName(String? groupName) {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isEqualTo: groupName)
        .get();
  }

  searchLessonByName(String? groupName) {
    return FirebaseFirestore.instance
        .collection("lessons")
        .where('lessonName', isEqualTo: groupName)
        .get();
  }
}
