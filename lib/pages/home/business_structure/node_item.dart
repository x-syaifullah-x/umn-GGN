import 'package:flutter/material.dart';
import 'package:global_net/pages/home/business_structure/node_model.dart';

typedef Callback = Function(NodeModel);

class NodeItem extends StatelessWidget {
  const NodeItem({
    Key? key,
    required this.model,
    this.onAdd,
    this.onRemove,
  }) : super(key: key);

  final NodeModel model;

  final Callback? onAdd;
  final Callback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: 130,
          child: Card(
            elevation: 8,
            child: LayoutBuilder(
              builder: (buildContext, boxConstraints) {
                return Column(
                  children: [
                    Container(
                      height: boxConstraints.maxWidth * .95,
                      color: Theme.of(context).primaryColor,
                    ),
                    Center(child: Text(model.name))
                  ],
                );
              },
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
            InkWell(
              onTap: () {
                onRemove?.call(model);
              },
              child: const Icon(Icons.remove_circle),
            ),
          ],
        )
      ],
    );
  }
}
