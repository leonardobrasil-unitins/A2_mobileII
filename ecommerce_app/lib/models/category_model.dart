class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
