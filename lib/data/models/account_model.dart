class AccountModel {
  final int id;
  final String name;
  final String type;
  final double balance;
  final String icon;
  final int colorValue;
  final String? description;

  AccountModel({
    required this.id, required this.name, required this.type,
    required this.balance, required this.icon, required this.colorValue,
    this.description,
  });

  String get normalizedType => type == 'wallet' ? 'cash' : type;

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
        id: map['id'] as int, name: map['name'] as String, type: map['type'] as String,
        balance: (map['balance'] as num).toDouble(), icon: map['icon'] as String,
        colorValue: map['colorValue'] as int, description: map['description'] as String?,
      );

  Map<String, dynamic> toInsertMap() => {
        'name': name, 'type': type, 'balance': balance,
        'icon': icon, 'colorValue': colorValue, 'description': description,
      };
}
