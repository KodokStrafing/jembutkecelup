class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final int colorValue;
  final String type;

  CategoryModel({
    required this.id, required this.name, required this.icon,
    required this.colorValue, required this.type,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as int, name: map['name'] as String, icon: map['icon'] as String,
        colorValue: map['colorValue'] as int, type: map['type'] as String,
      );

  Map<String, dynamic> toInsertMap() => {
        'name': name, 'icon': icon, 'colorValue': colorValue, 'type': type,
      };
}
