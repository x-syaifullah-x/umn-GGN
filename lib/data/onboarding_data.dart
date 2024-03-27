import 'package:flutter/foundation.dart';
import 'package:global_net/models/onboarding_model.dart';

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> walkThroughItems = [];
  const isNew = true;
  walkThroughItems.add(WalkThroughItemModel(
    image:
        isNew ? 'assets/images/network.png' : 'assets/images/walkthrough-3.png',
    title: isNew ? 'Global Girls Network!' : 'Upload Photos & Videos',
    subTitle: isNew
        ? 'Businesses, Suppliers, Consumers'
        : 'Share images and friends with your friends',
  ));
  walkThroughItems.add(WalkThroughItemModel(
    image: isNew
        ? 'assets/images/growbusiness.png'
        : 'assets/images/walkthrough-4.png',
    title: isNew ? 'Establish your business Network!' : 'Chat',
    subTitle: isNew
        ? 'Global clientele and supply chain'
        : 'Chat with others and make new friends all over the world.',
  ));
  walkThroughItems.add(WalkThroughItemModel(
    image: isNew
        ? 'assets/images/togeters.png'
        : 'assets/images/walkthrough-3.png',
    title: isNew ? 'Global Girls Network!' : 'Comment & React to Posts',
    subTitle: isNew
        ? 'Building Together, Shopping Together, Forever Together'
        : 'Comments and React to posts of users your following',
  ));
  walkThroughItems.add(WalkThroughItemModel(
    image:
        isNew ? 'assets/images/elevat.png' : 'assets/images/walkthrough-4.png',
    title: isNew ? 'Global Girls Network!' : 'Credit System',
    subTitle: isNew
        ? 'Create your Global Alliances'
        : 'Use credit points to see users who like, dislike, view or follow your profile, also use credit points to see users who like, dislike, view or follow other users, ',
  ));
  return walkThroughItems;
}
