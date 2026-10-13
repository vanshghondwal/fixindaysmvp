/// Admin console state: auth (email login + `admin:true` custom claim check)
/// and the active [AdminRepository] (demo vs Firestore).
///
/// SECURITY RULE (also enforced by firestore.rules):
/// admin authorization comes ONLY from the Firebase Auth custom claim
/// `admin: true` on the ID token. We NEVER read a Firestore field to decide
/// whether someone is an admin — any signed-in user could write such a field.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/foundation.dart';

import '../data/demo_admin.dart';
import '../data/firestore_admin.dart';

enum AdminAuthState { unknown, signedOut, demo, authorized, unauthorized }

class AdminState extends ChangeNotifier {
  AdminState({required bool demoMode}) {
    if (demoMode) {
      _repo = DemoAdminRepository();
      _demoMode = true;
      _authState = AdminAuthState.signedOut;
    } else {
      _repo = FirestoreAdminRepository();
      _demoMode = false;
      _authState = AdminAuthState.signedOut;
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          _authState = AdminAuthState.signedOut;
          _email = null;
          notifyListeners();
        }
      });
    }
  }

  late final AdminRepository _repo;
  AdminRepository get repo => _repo;
  DemoAdminRepository? get demoRepo =>
      _repo is DemoAdminRepository ? _repo as DemoAdminRepository : null;
  FirestoreAdminRepository? get firestoreRepo => _repo is FirestoreAdminRepository
      ? _repo as FirestoreAdminRepository
      : null;

  bool _demoMode = true;
  bool get demoMode => _demoMode;
  String? get repoLabel => _demoMode ? 'Demo data' : 'Firestore';

  AdminAuthState _authState = AdminAuthState.unknown;
  AdminAuthState get authState => _authState;

  String? _email;
  String? get email => _email;
  String get adminId => _email ?? 'unknown-admin';

  String? _error;
  String? get error => _error;

  bool _busy = false;
  bool get busy => _busy;

  /// Email login.
  ///
  /// Demo mode: accepts the demo admin `admin@fixindays.demo` with ANY
  /// password (clearly labelled in the UI). Real mode: Firebase email sign-in
  /// followed by a custom-claim check — users without `admin:true` are
  /// signed straight back out and shown "Not authorized".
  Future<bool> signIn(String email, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      if (_demoMode) {
        if (email.trim().toLowerCase() != 'admin@fixindays.demo') {
          throw StateError(
              'Demo mode: sign in as admin@fixindays.demo (any password).');
        }
        _email = email.trim();
        _authState = AdminAuthState.demo;
        return true;
      }
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      // Force a fresh token so a recently-granted claim is visible.
      final token = await cred.user!.getIdTokenResult(true);
      final isAdmin = token.claims?['admin'] == true;
      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();
        _authState = AdminAuthState.unauthorized;
        _error =
            'Not authorized: this account does not have admin access. Ask an existing admin to grant it (setAdminClaim).';
        return false;
      }
      _email = email.trim();
      _authState = AdminAuthState.authorized;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign-in failed (${e.code}).';
      return false;
    } on StateError catch (e) {
      _error = e.message;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (!_demoMode) {
      await FirebaseAuth.instance.signOut();
    }
    _authState = AdminAuthState.signedOut;
    _email = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
