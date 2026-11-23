import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _userProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get firebaseUser => _auth.currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoggedIn => firebaseUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    return _runAuthAction(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Account creation failed. Please try again.');
      await user.updateDisplayName(name.trim());
      final profile = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );
      await _firestore.collection('users').doc(user.uid).set(profile.toMap());
      _userProfile = profile;
    });
  }

  Future<bool> login({required String email, required String password}) async {
    return _runAuthAction(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) await loadUserProfile(user.uid);
    });
  }

  Future<void> loadUserProfile([String? uid]) async {
    final current = _auth.currentUser;
    final userId = uid ?? current?.uid;
    if (userId == null) return;
    try {
      final snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        _userProfile = UserModel.fromMap(snapshot.data()!, userId);
      } else if (current != null) {
        _userProfile = UserModel(
          uid: current.uid,
          name: current.displayName ?? '',
          email: current.email ?? '',
        );
      }
      notifyListeners();
    } catch (_) {
      // Authentication remains usable if profile data is temporarily unavailable.
    }
  }

  Future<bool> updateProfile({required String name, required String phone}) async {
    return _runAuthAction(() async {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Please sign in again.');
      await user.updateDisplayName(name.trim());
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'phone': phone.trim(),
        'email': user.email ?? '',
        'uid': user.uid,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      _userProfile = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: user.email ?? '',
        phone: phone.trim(),
        photoUrl: _userProfile?.photoUrl ?? '',
      );
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    return _runAuthAction(() async {
      await _auth.sendPasswordResetEmail(email: email.trim());
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _friendlyAuthError(error);
      return false;
    } on FirebaseException catch (error) {
      _errorMessage = error.message ?? 'A Firebase service error occurred.';
      return false;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use': return 'An account already exists for this email.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'weak-password': return 'Choose a stronger password (at least 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': return 'Email or password is incorrect.';
      case 'user-disabled': return 'This account has been disabled.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Check your internet connection.';
      default: return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
