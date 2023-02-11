import 'package:global_net/pages/home/business_structure/node_model.dart';

class EdgeModel {
  EdgeModel({
    required this.from,
    required this.to,
  });

  final NodeModel from;
  final NodeModel to;

  static const edgesKey = 'edges';
  static const edgeFromKey = 'from';
  static const edgeToKey = 'to';

  static List<EdgeModel> toList(Map<String, dynamic> json) {
    final List edges = json[edgesKey] ?? [];
    return edges.map((edge) {
      final from = edge[edgeFromKey];
      final to = edge[edgeToKey];
      return EdgeModel(
        from: NodeModel.fromJson(from),
        to: NodeModel.fromJson(to),
      );
    }).toList();
  }
}
