import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class Friends extends StatefulWidget {
  final String userId;
  final String? excludeId;

  const Friends({
    Key? key,
    required this.userId,
    this.excludeId,
  }) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
          centerTitle: true,
          title: Text(
            'Friends',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),

        // body: RefreshIndicator(
        //     child: PaginateFirestore(
        //       // scrollController: scrollController,
        //       shrinkWrap: true,
        //       isLive: true,
        //       itemBuilderType: PaginateBuilderType.pageView,
        //       query: followingCollection
        //           .doc(widget.userId)
        //           .collection('userFollowing')
        //           .where('value', isEqualTo: true),
        //       itemBuilder: (context, documentSnapshot, index) {
        //         final userDoc = documentSnapshot[index];
        //         return _Item(
        //           userId: widget.userId,
        //           followingId: userDoc.id,
        //         );
        //       },
        //     ),
        //     onRefresh: () async {
        //       // refreshChangeListener.refreshed = true;
        //     }),

        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: followingCollection
              .doc(widget.userId)
              .collection('userFollowing')
              .where('value', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            int crossAxisCount = 4;
            final width = MediaQuery.of(context).size.width;
            if (width < 500) {
              crossAxisCount = 2;
            } else if (width < 1000) {
              crossAxisCount = 3;
            }
            final double itemHeight = (size.height - kToolbarHeight - 24) / 3.5;
            final double itemWidth = size.width / crossAxisCount;
            return GridView.count(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisCount: crossAxisCount,
              children: [
                if (widget.userId != widget.excludeId)
                  _Item(
                    userId: widget.userId,
                    followingId: widget.userId,
                  ),
                ...docs
                    .where((element) => element.id != widget.excludeId)
                    .map((doc) => _Item(
                          userId: widget.userId,
                          followingId: doc.id,
                        ))
                    .toList()
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Item extends StatefulWidget {
  final String userId;
  final String followingId;
  const _Item({
    Key? key,
    required this.userId,
    required this.followingId,
  }) : super(key: key);

  @override
  State<_Item> createState() => __ItemState();
}

class __ItemState extends State<_Item> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: usersCollection.doc(widget.followingId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        final user = User.fromJson(snapshot.data?.data());
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop({
              'user': user,
            });
          },
          child: Container(
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).shadowColor,
              ),
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: <Widget>[
                    user.coverUrl.isEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/defaultcover_new.jpg',
                              alignment: Alignment.center,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 60,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: user.coverUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    user.username.isNotEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              // image: DecorationImage(
                              //     image: CachedNetworkImageProvider(user.coverUrl,
                              //         scale: 1.0),
                              //     fit: BoxFit.cover)
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: Container(
                                alignment: const Alignment(0.0, 5.5),
                                child: user.photoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: CachedNetworkImage(
                                          imageUrl: user.photoUrl,
                                          height: 50.0,
                                          width: 50.0,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF003a54),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Image.asset(
                                          'assets/images/defaultavatar.png',
                                          width: 50,
                                        ),
                                      ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  user.username,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 12,
                    left: 16,
                    right: 16,
                  ),
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.redAccent[700],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Select',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).onTap(() {
                  Navigator.of(context).pop({
                    'user': user,
                  });
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
