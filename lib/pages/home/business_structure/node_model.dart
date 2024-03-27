class NodeModel {
  final String id;
  final String userId;
  final String title;

  NodeModel({
    required this.id,
    required this.userId,
    required this.title,
  });

  static const keyNodes = 'nodes';
  static const _keyId = 'id';
  static const _keyUserId = 'user_id';
  static const _keyTitle = 'title';

  static List<NodeModel> toList(Map<String, dynamic>? json) {
    final List values = json?[keyNodes] ?? [];
    return values.map((value) {
      return NodeModel.fromJson(value);
    }).toList();
  }

  NodeModel.fromJson(Map<String, dynamic> json)
      : id = json[_keyId],
        userId = json[_keyUserId],
        title = json[_keyTitle];

  Map<String, dynamic> toJson() => {
        _keyId: id,
        _keyUserId: userId,
        _keyTitle: title,
      };

  @override
  String toString() {
    return 'NodeModel{id: $id, user_id: $userId}';
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
