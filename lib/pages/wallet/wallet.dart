import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/coupon/coupon.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/wallet/buy_credits.dart';
import 'package:global_net/pages/wallet/models/transaction_model.dart';
import 'package:global_net/pages/wallet/transfer.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class Wallet extends StatefulWidget {
  final User user;

  const Wallet({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _body(userId: widget.user.id),
      ),
    );
  }

  Widget _body({required String userId}) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: usersCollection.doc(userId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        final user = User.fromJson(data);

        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  user.photoUrl.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF003a54),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.asset(
                            'assets/images/defaultavatar.png',
                            width: 45,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: user.photoUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          imageBuilder: (context, imageProvider) => ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image(
                              image: imageProvider,
                              height: 45,
                              width: 45,
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    user.displayName,
                    style: GoogleFonts.portLligatSans(
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
              8.height,
              _balanceWidget(context, user),
              8.height,
              _menuWidget(context, user),
              16.height,
              Container(
                margin: const EdgeInsets.only(left: 16),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _transactionsWidget(userId: userId),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _transactionsWidget({
    required String userId,
    String orderBy = 'createAt',
    bool descending = true,
    int limit = 50,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore
          .collection('wallets')
          .doc(userId)
          .collection('transactions')
          .orderBy(orderBy, descending: descending)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const CupertinoActivityIndicator();
        }
        final docs = data.docs;
        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final transaction = TransactionModel.fromJson(doc.data());
            String? walletId;
            if (transaction.type == Type.transfer) {
              walletId = transaction.receiver;
            }
            if (transaction.type == Type.receive) {
              walletId = transaction.sender;
            }
            if (walletId != null) {
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: usersCollection.doc(walletId).snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  if (data != null) {
                    return _transactionItem(
                      user: User.fromJson(data),
                      transaction: transaction,
                    );
                  }
                  return _transactionItem(transaction: transaction);
                },
              );
            }
            return _transactionItem(transaction: transaction);
          },
        );
      },
    );
  }

  Widget _transactionItem({
    User? user,
    required TransactionModel transaction,
  }) {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemTransactionIcon(
              url: transaction.sender == 'stripe'
                  ? 'https://asset.brandfetch.io/idxAg10C0L/idTHPdqoDR.jpeg'
                  : user?.photoUrl ?? '',
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _itemTransactionTitle(transaction.type),
                  const SizedBox(
                    height: 4,
                  ),
                  _itemTransactionSubTitle(user, transaction),
                  const SizedBox(
                    height: 8,
                  ),
                  _itemTransactionBody(transaction),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemTransactionBody(TransactionModel transaction) {
    final bool isTransfer = transaction.type == Type.transfer;
    final bool isCreateCoupon = transaction.type == Type.create_coupon;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DateTime.fromMillisecondsSinceEpoch(transaction.createAt)}',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          transaction.amount > 0
              ? '${isTransfer || isCreateCoupon ? '-' : '+'}${transaction.amount}'
              : '0',
          style: TextStyle(
            color: transaction.amount > 0
                ? isTransfer || isCreateCoupon
                    ? Colors.red
                    : Colors.green
                : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _itemTransactionSubTitle(User? user, TransactionModel transaction) {
    final type = transaction.type;

    String title = 'Unknown';
    if (type == Type.transfer) {
      title = 'To ${user?.displayName ?? transaction.receiver}';
    }

    if (type == Type.receive) {
      title = 'From ${user?.displayName ?? transaction.sender}';
    }

    if (type == Type.purchase) {
      title = 'From ${transaction.sender.toString().capitalize()}';
    }

    if (type == Type.create_coupon) {
      title = 'To ${transaction.sender.toString().capitalize()}';
    }

    if (type == Type.delete_coupon) {
      title = 'From ${transaction.sender.toString().capitalize()}';
    }

    if (type == Type.refund) {
      title = 'From ${transaction.sender.toString().capitalize()}';
    }
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _itemTransactionTitle(Type transactionType) {
    String title = 'Unknown';
    if (transactionType == Type.transfer) title = 'Transfer';
    if (transactionType == Type.receive) title = 'Received';
    if (transactionType == Type.purchase) title = 'Purchase';
    if (transactionType == Type.create_coupon) title = 'Create Coupon';
    if (transactionType == Type.delete_coupon) title = 'Delete Coupon';
    if (transactionType == Type.refund) title = 'Refund';
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _itemTransactionIcon({required String url}) {
    const radius = 16.0;
    const width = 40.0;
    const height = 40.0;
    if (url.isEmptyOrNull) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/images/defaultavatar.png',
          width: width,
          height: height,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => const CupertinoActivityIndicator(),
      errorWidget: (context, url, error) => const Icon(
        Icons.error,
        size: 40,
      ),
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image(
          image: imageProvider,
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget _menuWidget(BuildContext context, User user) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _menuItemWidget(
              icon: const Icon(
                Icons.credit_card,
              ),
              title: 'Buy Credits',
              onItemClick: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return BuyCredits(user: user);
                    },
                  ),
                );
              }),
          _menuItemWidget(
              icon: const Icon(
                Icons.send,
              ),
              title: 'Transfer',
              onItemClick: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Transfer(userId: user.id);
                    },
                  ),
                );
              }),
          _menuItemWidget(
              icon: const Icon(
                Icons.currency_exchange_rounded,
              ),
              title: 'Coupon',
              onItemClick: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return CouponPage(user: user);
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _menuItemWidget({
    required Icon icon,
    required String title,
    Function? onItemClick,
  }) {
    return GestureDetector(
      onTap: () {
        onItemClick?.call();
      },
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: SizedBox(
              height: 45,
              width: 70,
              child: icon,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _balanceWidget(BuildContext context, User user) {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: MediaQuery.of(context).size.width * .85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Wallet ID',
                  style: GoogleFonts.portLligatSans(
                    textStyle: Theme.of(context).textTheme.headlineMedium,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                InkWell(
                  child: const Icon(
                    Icons.copy_all_sharp,
                    size: 18,
                  ),
                  onTap: () async {
                    try {
                      await Clipboard.setData(
                        ClipboardData(
                          text: widget.user.id,
                        ),
                      );
                      toast('Wallet ID has been successfully copied');
                    } catch (e) {
                      log('$e');
                    }
                  },
                ),
                Text(
                  user.id,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Total Balance',
              style: GoogleFonts.portLligatSans(
                textStyle: Theme.of(context).textTheme.headlineMedium,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Credits ${user.creditPoints} = USD \$${(user.creditPoints / 100.00).toStringAsFixed(2)}',
              style: GoogleFonts.portLligatSans(
                textStyle: Theme.of(context).textTheme.headlineMedium,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
