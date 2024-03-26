import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  static const String fieldNameCreditPoints = 'credit_points';
  static const String fieldNameDisplayName = 'displayName';
  static const String fieldNameEmail = 'email';
  static const String fieldNameGroups = 'groups';
  static const String fieldNameId = 'id';
  static const String fieldNameLoginType = 'loginType';
  static const String fieldNameNoAds = 'no_ads';
  static const String fieldNamePhotoUrl = 'photoUrl';
  static const String fieldNameTimestamp = 'timestamp';
  static const String fieldNameTokenNotfaction = 'tokenNotification';
  static const String fieldNameUserIsVerified = 'userIsVerified';
  static const String fieldNameUsername = 'username';
  static const String fieldNameBio = 'bio';
  static const String fieldNameCoverUrl = 'coverUrl';
  static const String fieldNameActive = 'active';

  final int creditPoints;
  final String displayName;
  final String email;
  final List<dynamic> groups;
  final String id;
  final String loginType;
  final bool noAds;
  final String photoUrl;
  final int timestamp;
  final String tokenNotfaction;
  final bool userIsVerified;
  final String username;
  final String bio;
  final String coverUrl;
  final bool active;

  const User({
    required this.bio,
    required this.coverUrl,
    required this.creditPoints,
    required this.displayName,
    required this.email,
    required this.groups,
    required this.id,
    required this.loginType,
    required this.noAds,
    required this.photoUrl,
    required this.timestamp,
    required this.tokenNotfaction,
    required this.userIsVerified,
    required this.username,
    required this.active,
  });

  factory User.fromJson(Map<String, dynamic>? json) => User(
        bio: json?[fieldNameBio] ?? '',
        coverUrl: json?[fieldNameCoverUrl] ?? '',
        creditPoints: json?[fieldNameCreditPoints] ?? 0,
        displayName: json?[fieldNameDisplayName] ?? '',
        email: json?[fieldNameEmail] ?? '',
        groups: json?[fieldNameGroups] ?? [],
        id: json?[fieldNameId] ?? '',
        loginType: json?[fieldNameLoginType] ?? '',
        noAds: json?[fieldNameNoAds] ?? '',
        photoUrl: json?[fieldNamePhotoUrl] ?? '',
        timestamp: _getTimesTamp(json?[fieldNameTimestamp]),
        tokenNotfaction: json?[fieldNameTokenNotfaction] ?? '',
        userIsVerified: json?[fieldNameUserIsVerified] ?? '',
        username: json?[fieldNameUsername] ?? '',
        active: json?[fieldNameActive] ?? true,
      );

  dynamic chech(Function a) {
    try {
      return a.call();
    } catch (e) {
      return '';
    }
  }

  static int _getTimesTamp(dynamic) {
    if (dynamic is Timestamp) {
      return dynamic.millisecondsSinceEpoch;
    }
    return dynamic;
  }

  Map<String, dynamic> toJson() => {
        fieldNameBio: bio,
        fieldNameCoverUrl: coverUrl,
        fieldNameCreditPoints: creditPoints,
        fieldNameDisplayName: displayName,
        fieldNameEmail: email,
        fieldNameGroups: groups,
        fieldNameId: id,
        fieldNameLoginType: loginType,
        fieldNameNoAds: noAds,
        fieldNamePhotoUrl: photoUrl,
        fieldNameTimestamp: timestamp,
        fieldNameTokenNotfaction: tokenNotfaction,
        fieldNameUserIsVerified: userIsVerified,
        fieldNameUsername: username,
        fieldNameActive: active,
      };
}
