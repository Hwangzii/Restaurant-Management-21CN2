// models/account.dart
class Account {
  final int id;
  final String username;
  final String email;
  final String phoneNumber;

  Account({required this.id, required this.username, required this.email, required this.phoneNumber});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }
}
