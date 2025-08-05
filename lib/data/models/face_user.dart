class FaceUser {
  String id;
  String name;
  final List<double> vectorList;

  FaceUser(this.id, this.name, this.vectorList);

  FaceUser copyWith({String? id, String? name, List<double>? list}) {
    return FaceUser(
        id ?? this.id,
        name ?? this.name,
        list ?? vectorList
    );
  }
}