import 'package:cloud_firestore/cloud_firestore.dart';

class GloabalUser {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final int creditPoints;
  final String coverUrl;
  final bool userIsVerified;
  final bool noAds;
  String activeVipId = '';

  GloabalUser({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.creditPoints,
    required this.noAds,
    required this.coverUrl,
    required this.userIsVerified,
  });

  factory GloabalUser.fromDocument(DocumentSnapshot doc) {
    return GloabalUser(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      creditPoints: 100,
      coverUrl: doc['coverUrl'],
      userIsVerified: false,
      noAds: false,
    );
  }

  factory GloabalUser.fromMap(Map<String, dynamic> map) {
    return GloabalUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      creditPoints: map['credit_points'] ?? 0,
      coverUrl: map['coverUrl'] as String? ?? '',
      userIsVerified: map['userIsVerified'] ?? false,
      noAds: map['no_ads'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'bio': bio,
      'credit_points': creditPoints,
      'searchIndexes': searchIndexes,
      'coverUrl': coverUrl,
      'userIsVerified': userIsVerified,
      'no_ads': noAds,
    };
  }

  List<String> get searchIndexes {
    final indices = <String>[];
    for (final s in [username, displayName]) {
      for (var i = 1; i < s.length; i++) {
        indices.add(s.substring(0, i).toLowerCase());
      }
    }
    return indices;
  }

  static final usersCol =
      FirebaseFirestore.instance.collection('users').withConverter<GloabalUser>(
            fromFirestore: (e, _) => GloabalUser.fromMap(e.data()!),
            toFirestore: (m, _) => m.toMap(),
          );

  static DocumentReference<GloabalUser> userDoc([String? id]) =>
      usersCol.doc(id);

  static Future<GloabalUser?> fetchUser([String? id]) async {
    final doc = await userDoc(id).get();
    return doc.data();
  }
}
