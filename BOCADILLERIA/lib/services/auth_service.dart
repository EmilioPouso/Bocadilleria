import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('SIGNIN_ERROR: $e');
      throw Exception(_loginErrorMessage(e));
    } catch (e) {
      debugPrint('SIGNIN_ERROR: $e');
      throw Exception('Correo o contraseña incorrectos');
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _db.child('users').child(user.uid).set({
          'email': email,
          'role': 'user',
          'createdAt': ServerValue.timestamp,
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('REGISTER_ERROR: $e');
      throw Exception(_registerErrorMessage(e));
    } catch (e) {
      debugPrint('REGISTER_ERROR: $e');
      throw Exception('No se pudo crear la cuenta');
    }
  }

  Future<User?> signInWithGoogle() async {
    // Implementation for Google Sign In would go here
    return null; 
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final snapshot = await _db.child('users').child(uid).child('role').get();
      return snapshot.value as String?;
    } catch (e) {
      debugPrint('GET_ROLE_ERROR: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _loginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Correo o contraseña incorrectos';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'user-disabled':
        return 'Esta cuenta está desactivada';
      default:
        return 'Correo o contraseña incorrectos';
    }
  }

  String _registerErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'El correo no es válido';
      default:
        return 'No se pudo crear la cuenta';
    }
  }
}
