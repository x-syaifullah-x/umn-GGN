import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/pages/comming_soon_page.dart';
import 'package:global_net/pages/home/business_structure/friends.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/home/profile/profile.dart';
import 'package:graphview/GraphView.dart';

import 'edge_model.dart';
import 'node_item.dart';
import 'node_model.dart';
import 'package:global_net/data/user.dart' as data_user;

class BusinessStructure extends StatefulWidget {
  const BusinessStructure({
    Key? key,
  }) : super(key: key);

  @override
  State<BusinessStructure> createState() => _BusinessStructureState();
}

class _BusinessStructureState extends State<BusinessStructure> {
  final random = Random();

  final Graph graph = Graph()..isTree = true;

  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration()
    ..siblingSeparation = (50)
    ..levelSeparation = (50)
    ..subtreeSeparation = (50)
    ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

  final _textEditingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final fAuth = FirebaseAuth.instance;
    final user = fAuth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final primaryColor = Theme.of(context).primaryColor;
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryColor, //change your color here
          ),
          title: Text(
            AppLocalizations.of(context)?.business_structure ?? '',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _getBusinessStructureDoc(uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CupertinoActivityIndicator(animating: true),
                );
              }

              if (snapshot.connectionState == ConnectionState.active) {
                graph.nodes.clear();
                graph.edges.clear();
                final data = snapshot.data?.data() ?? {};
                final List<NodeModel> nodes = NodeModel.toList(data);
                final List<EdgeModel> edges = EdgeModel.toList(data);
                for (var element in edges) {
                  graph.addEdge(Node.Id(element.from), Node.Id(element.to));
                }

                if (edges.isEmpty && nodes.isNotEmpty) {
                  graph.addNode(Node.Id(nodes.first));
                }
                return graph.nodeCount() == 0
                    ? Center(
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _showFormAdd(userID: uid);
                          },
                        ),
                      )
                    : InteractiveViewer(
                        constrained: false,
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.01,
                        maxScale: 5.6,
                        child: GraphView(
                          animated: true,
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(
                            builder,
                            TreeEdgeRenderer(builder),
                          ),
                          paint: Paint()
                            ..color = Theme.of(context).primaryColor
                            ..strokeWidth = 1.5
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) {
                            final model = node.key?.value as NodeModel;
                            return NodeItem(
                              key: Key(model.id),
                              model: model,
                              onEdit: (model) {
                                changeTitle(userID: uid, model: model);
                              },
                              onTap: () {
                                usersCollection.doc(model.userId).get().then(
                                  (value) {
                                    final user =
                                        data_user.User.fromJson(value.data());
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => Profile(
                                          ownerId: uid,
                                          reactions: const [],
                                          user: user,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              onAdd: (model) {
                                _showFormAdd(
                                  userID: uid,
                                  source: model,
                                );
                              },
                              onRemove: (model) {
                                _removeNode(userUID: uid, model: model);
                              },
                            );
                          },
                        ),
                      );
              }
              throw UnimplementedError();
            },
          ),
        ),
      );
    }
    return const Text('no user data');
  }

  void changeTitle({
    required String userID,
    required NodeModel model,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                focusNode: focusNode,
                controller: _textEditingController,
                decoration: const InputDecoration(
                  label: Text(
                    'Enter Title',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    ),
                    // borderRadius: BorderRadius.circular(50.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: const Text('Ok'),
              onPressed: () {
                final title = _textEditingController.text;
                if (title.isEmpty) {
                  focusNode.requestFocus();
                  return;
                }
                _getBusinessStructureDoc(userID).get().then((value) {
                  final data = value.data();
                  final edges = EdgeModel.toList(data);
                  final nodes = NodeModel.toList(data);
                  final aa = edges.map((e) {
                    if (e.to.id == model.id) {
                      return EdgeModel(
                        from: e.from,
                        to: NodeModel(
                          id: e.to.id,
                          title: title,
                          userId: e.to.userId,
                        ),
                      );
                    } else if (e.from.id == model.id) {
                      return EdgeModel(
                        to: e.to,
                        from: NodeModel(
                          id: e.from.id,
                          title: title,
                          userId: e.from.userId,
                        ),
                      );
                    } else {
                      return e;
                    }
                  }).toList();

                  final bb = nodes.map((e) {
                    if (e.id == model.id) {
                      return NodeModel(
                        id: e.id,
                        userId: e.userId,
                        title: title,
                      );
                    } else {
                      return e;
                    }
                  }).toList();
                  _getBusinessStructureDoc(userID).update({
                    'edges': aa
                        .map((e) => {
                              'from': {
                                'id': e.from.id,
                                'title': e.from.title,
                                'user_id': e.from.userId,
                              },
                              'to': {
                                'id': e.to.id,
                                'title': e.to.title,
                                'user_id': e.to.userId,
                              }
                            })
                        .toList(),
                    'nodes': bb
                        .map((e) => {
                              'id': e.id,
                              'title': e.title,
                              'user_id': e.userId,
                            })
                        .toList(),
                  }).then((value) => null);
                });
                //
                _textEditingController.clear();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _showFormAdd({required String userID, NodeModel? source}) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => Friends(
          userId: userID,
          excludeId: source?.userId,
        ),
      ),
    )
        .then((value) {
      if (value.toString().contains('user')) {
        final user = value['user'] as data_user.User;
        setTitle(userID: userID, user: user, source: source);
      }
    });
  }

  void setTitle({
    required String userID,
    required data_user.User user,
    NodeModel? source,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                focusNode: focusNode,
                controller: _textEditingController,
                decoration: const InputDecoration(
                  label: Text(
                    'Enter Title',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    ),
                    // borderRadius: BorderRadius.circular(50.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: const Text('Ok'),
              onPressed: () {
                final title = _textEditingController.text;
                if (title.isEmpty) {
                  focusNode.requestFocus();
                  return;
                }
                if (source == null) {
                  _addNode(
                    userUID: userID,
                    key: NodeModel(
                      id: '1',
                      userId: user.id,
                      title: title,
                    ),
                  );
                } else {
                  _addNode(
                    userUID: userID,
                    key: source,
                    destination: NodeModel(
                      id: '${random.nextInt(1000000)}',
                      userId: user.id,
                      title: title,
                    ),
                  );
                }
                _textEditingController.clear();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _addNode({
    required String userUID,
    required NodeModel key,
    NodeModel? destination,
  }) {
    try {
      final des = graph.getNodeUsingId(destination);
      debugPrint('data $des exist');
    } catch (e) {
      if (graph.nodeCount() == 0 && destination == null) {
        graph.addNode(Node.Id(key));
      } else {
        final source = graph.getNodeUsingId(key);
        graph.addEdge(source, Node.Id(destination));
      }
      _updateGraphInFirebase(userUID: userUID);
    }
  }

  void _removeNode({required String userUID, required NodeModel model}) {
    final current = graph.getNodeUsingId(model);
    final child = graph.edges.where((element) {
      return element.source == current;
    }).toList();
    if (child.isNotEmpty) {
      for (var element in child) {
        graph.removeNode(element.destination);
      }
    } else {
      graph.removeNode(current);
    }
    _updateGraphInFirebase(userUID: userUID);
  }

  void _updateGraphInFirebase({required String userUID}) {
    _getBusinessStructureDoc(userUID).set({
      NodeModel.keyNodes: graph.nodes.map((node) {
        final model = node.key?.value as NodeModel;
        return model.toJson();
      }).toList(),
      EdgeModel.keyEdges: graph.edges.map((edge) {
        final from = edge.source.key?.value as NodeModel;
        final to = edge.destination.key?.value as NodeModel;
        return {
          EdgeModel.keyEdgesFrom: from.toJson(),
          EdgeModel.keyEdgesTo: to.toJson(),
        };
      }).toList(),
    });
  }

  DocumentReference<Map<String, dynamic>> _getBusinessStructureDoc(String uid) {
    final collectionBusinessStructure =
        FirebaseFirestore.instance.collection('business_structure');
    return collectionBusinessStructure.doc(uid);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
