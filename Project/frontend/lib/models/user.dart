class User {
  final int id;
  final String username;
  final String password;
  final String name;
  final String userPhone;
  final String email;
  // final String key;
  final String createdAt;
  // final bool is2faEnabled;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.userPhone,
    required this.email,
    // required this.key,
    required this.createdAt,
    // required this.is2faEnabled,
  });

  // Hàm factory để khởi tạo User từ Map (API trả về)
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      email: json['email'] ?? '',
      // key: data['key'],
      createdAt: json['created_at'] ?? '',
      // is2faEnabled: data['is_2fa_enabled'],
    );
  }
}
