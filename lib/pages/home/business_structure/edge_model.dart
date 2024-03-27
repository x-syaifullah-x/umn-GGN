import 'package:global_net/pages/home/business_structure/node_model.dart';

class EdgeModel {
  EdgeModel({
    required this.from,
    required this.to,
  });

  final NodeModel from;
  final NodeModel to;

  static const keyEdges = 'edges';
  static const keyEdgesFrom = 'from';
  static const keyEdgesTo = 'to';

  static List<EdgeModel> toList(Map<String, dynamic>? json) {
    final List edges = json?[keyEdges] ?? [];
    return edges.map((edge) {
      final from = edge[keyEdgesFrom];
      final to = edge[keyEdgesTo];
      return EdgeModel(
        from: NodeModel.fromJson(from),
        to: NodeModel.fromJson(to),
      );
    }).toList();
  }
}
