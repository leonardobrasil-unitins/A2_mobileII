class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String password;

  String get firstName => name.split(' ').first;

  Map<String, dynamic> toSessionMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': '',
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}
