import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _role;
  bool _isLoading = true;

  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _role = await _authService.getUserRole(user.uid);
      } else {
        _role = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _role == 'admin';

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.register(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    final user = await _authService.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
