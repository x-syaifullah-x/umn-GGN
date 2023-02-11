class NodeModel {
  NodeModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

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
      : id = int.tryParse('${json[_idKey]}') ?? 0,
        name = json[_nameKey];

  Map<String, dynamic> toJson() => {
        _idKey: id,
        _nameKey: name,
      };

  @override
  String toString() {
    return 'NodeModel{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
