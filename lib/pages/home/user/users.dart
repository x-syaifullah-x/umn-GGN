import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/user/user.dart';
import 'package:global_net/widgets/header.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../../ads/applovin_ad_unit_id.dart';

class Users extends StatefulWidget {
  final String userId;

  const Users({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<Users> createState() => _Users();
}

class _Users extends State<Users> with AutomaticKeepAliveClientMixin<Users> {
  final PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  final ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool widthMoreThan_500 = (MediaQuery.of(context).size.width > 500);
    return Scaffold(
      appBar: header(
        context,
        titleText: AppLocalizations.of(context)!.recent_users,
        removeBackButton: false,
      ),
      body: RawScrollbar(
        controller: scrollController,
        interactive: true,
        thumbVisibility: !kIsWeb && widthMoreThan_500,
        trackVisibility: !kIsWeb && widthMoreThan_500,
        radius: const Radius.circular(20),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                  child: PaginateFirestore(
                    scrollController: scrollController,
                    shrinkWrap: true,
                    isLive: true,
                    itemBuilderType: PaginateBuilderType.gridView,
                    query:
                        usersCollection.orderBy('timestamp', descending: true),
                    itemBuilder: (context, documentSnapshot, index) {
                      final userDoc = documentSnapshot[index].data()
                          as Map<String, dynamic>;
                      return User(
                        currentUserId: widget.userId,
                        userId: userDoc['id'],
                      );
                    },
                  ),
                  onRefresh: () async {
                    refreshChangeListener.refreshed = true;
                  }),
            ),
            // const AdsWidget()
            if (!kIsWeb)
              MaxAdView(
                adUnitId: AppLovin.adUnitId,
                adFormat: AdFormat.banner,
                listener: AdViewAdListener(
                  onAdLoadedCallback: (ad) {},
                  onAdLoadFailedCallback: (adUnitId, error) {},
                  onAdClickedCallback: (ad) {},
                  onAdExpandedCallback: (ad) {},
                  onAdCollapsedCallback: (ad) {},
                ),
              )
          ],
        ),
      ),
    );
  }
}
