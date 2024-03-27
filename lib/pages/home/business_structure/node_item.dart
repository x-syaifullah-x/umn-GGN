import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/home/business_structure/node_model.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:nb_utils/nb_utils.dart';

typedef Callback = Function(NodeModel);

class NodeItem extends StatelessWidget {
  final NodeModel model;
  final Callback? onAdd;
  final Callback? onRemove;
  final Callback? onEdit;
  final Function? onTap;

  const NodeItem({
    Key? key,
    required this.model,
    this.onAdd,
    this.onRemove,
    this.onEdit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: usersCollection.doc(model.userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            width: 130,
            child: Card(
              elevation: 8,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          );
        }

        final user = User.fromJson(snapshot.data?.data());

        return Column(
          children: [
            InkWell(
              onTap: () {
                onTap?.call();
              },
              child: Container(
                constraints: const BoxConstraints(minWidth: 140),
                child: Card(
                  elevation: 8,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 8,
                          right: 8,
                          bottom: 8,
                        ),
                        child: user.photoUrl.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF003a54),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Image.asset(
                                  'assets/images/defaultavatar.png',
                                  // width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Material(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: user.photoUrl.isEmpty
                                    ? Image.asset(
                                        'assets/images/defaultavatar.png',
                                        // width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: user.photoUrl,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          user.displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      8.height,
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          model.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      8.height,
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    onAdd?.call(model);
                  },
                  child: const Icon(Icons.add_circle),
                ),
                8.width,
                InkWell(
                  onTap: () {
                    onRemove?.call(model);
                  },
                  child: const Icon(Icons.remove_circle),
                ),
                8.width,
                InkWell(
                  onTap: () {
                    onEdit?.call(model);
                  },
                  child: const Icon(Icons.edit_document),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
