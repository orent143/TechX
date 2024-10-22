class User {
  final String username;
  final String password;
  final String email;
  final String address;

  User(this.username, this.password, this.email, this.address);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['username'],
      json['password'],
      json['email'],
      json['address'],
    );
  }
}
