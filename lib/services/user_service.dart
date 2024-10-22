import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';

class UserService {
  List<User> _users = [];

  Future<void> loadUsers() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> data = json.decode(response);
      _users = data.map((userJson) => User.fromJson(userJson)).toList();
      print(
          "Loaded users: ${_users.map((user) => user.username).toList()}"); // Check loaded users
    } catch (e) {
      print("Error loading users: ${e.toString()}");
    }
  }

  User? authenticate(String username, String password) {
    print(
        "Attempting to login with: '$username' / '$password'"); // Quotes to see spaces
    print("Existing users: ${_users.map((user) => user.username).toList()}");

    try {
      return _users.firstWhere(
        (user) {
          print(
              "Comparing with: '${user.username}' / '${user.password}'"); // Debug print
          return user.username == username && user.password == password;
        },
      );
    } catch (e) {
      print("Login failed: ${e.toString()}");
      return null;
    }
  }
}
