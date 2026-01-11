import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/db_service.dart';

class AuthProvider with ChangeNotifier {
  User? currentUser;

  AuthProvider() { 
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final db = DBService.instance;
      final dbInstance = await db.database;
      final users = await dbInstance.query('users', where: 'id = ?', whereArgs: [userId]);
      if (users.isNotEmpty) {
        currentUser = User.fromMap(users.first);
        notifyListeners();
      }
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Inscription
  Future<bool> register(String username, String email, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final user = User(username: username, email: email, passwordHash: hashedPassword);
      final db = DBService.instance;

      final existingUser = await db.getUserByEmail(email);
      if (existingUser != null) return false;

      final createdUser = await db.createUser(user);
      currentUser = createdUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', createdUser.id!);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error registering: $e');
      return false;
    }
  }

  // Login email/password
  Future<bool> login(String email, String password) async {
    try {
      final db = DBService.instance;
      final user = await db.getUserByEmail(email);
      if (user == null) return false;

      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) return false;

      currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> updateUserProfile({
  String? username,
  String? photoPath,
  String? newPassword,
}) async {
  if (currentUser == null) return;

  String? passwordHash;
  if (newPassword != null && newPassword.isNotEmpty) {
    passwordHash = _hashPassword(newPassword);
  }

  // Crée un nouvel objet User avec copyWith
  final updatedUser = currentUser!.copyWith(
    username: username,
    photoPath: photoPath,
    passwordHash: passwordHash,
  );

  final db = DBService.instance;
  await db.updateUser(updatedUser);

  currentUser = updatedUser;
  notifyListeners();
}

}
