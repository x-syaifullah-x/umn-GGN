class NodeModel {
  final String id;
  final String userId;

  NodeModel({
    required this.id,
    required this.userId,
  });

  static const nodesKey = 'nodes';
  static const _idKey = 'key';
  static const _nameKey = 'name';

  static List<NodeModel> toList(Map<String, dynamic> data) {
    final List value = data['nodes'] ?? [];
    return value.map((e) {
      return NodeModel.fromJson(e);
    }).toList();
  }

  NodeModel.fromJson(Map<String, dynamic> json)
      // : id = int.tryParse('${json[_idKey]}') ?? 0,
      : id = json[_idKey],
        userId = json[_nameKey];

  Map<String, dynamic> toJson() => {
        _idKey: id,
        _nameKey: userId,
      };

  @override
  String toString() {
    return 'NodeModel{id: $id, name: $userId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
