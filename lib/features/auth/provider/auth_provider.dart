// =============================================================
// FILE: lib/features/auth/provider/auth_provider.dart
// TANGGUNG JAWAB: Auth Firebase — email/password DAN Google
//   Sign In yang beneran. Ada error state yang jelas supaya
//   tidak ada case "langsung masuk tanpa isi apa-apa".
// =============================================================

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn       _google    = GoogleSignIn();

  AuthStatus _status = AuthStatus.unknown;
  User?      _user;
  String?    _errorMessage;
  bool       _loading = false;

  AuthStatus get status       => _status;
  User?      get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get loading      => _loading;
  bool       get isLoggedIn   => _status == AuthStatus.authenticated;
  String     get displayName  => _user?.displayName ?? _user?.email?.split('@').first ?? 'Pengguna';
  String     get uid          => _user?.uid ?? '';

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user   = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Login Email/Password ──────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    // Validasi dasar SEBELUM panggil Firebase — mencegah submit kosong
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Email dan password wajib diisi';
      notifyListeners();
      return false;
    }
    if (!email.contains('@')) {
      _errorMessage = 'Format email tidak valid';
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal masuk, periksa koneksi internet';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Register Email/Password ───────────────────────────────
  Future<bool> register({
    required String name, required String email, required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Semua field wajib diisi';
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _errorMessage = 'Password minimal 6 karakter';
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
      await cred.user?.updateDisplayName(name.trim());
      await _createUserProfile(cred.user!.uid, name.trim(), email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mendaftar, periksa koneksi internet';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Google Sign In — IMPLEMENTASI NYATA ───────────────────
  Future<bool> signInWithGoogle() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Munculkan dialog pilih akun Google
      final googleUser = await _google.signIn();

      // Pengguna menekan "Cancel" di dialog Google
      if (googleUser == null) {
        _errorMessage = null; // bukan error, user sengaja batal
        _loading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      // Kalau user baru (belum ada profil di Firestore), buat profil
      final doc = await _firestore.collection('users').doc(userCred.user!.uid).get();
      if (!doc.exists) {
        await _createUserProfile(
          userCred.user!.uid,
          userCred.user!.displayName ?? 'Pengguna',
          userCred.user!.email ?? '',
        );
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal masuk dengan Google, coba lagi';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> _createUserProfile(String uid, String name, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name, 'email': email,
      'friendCode': _generateFriendCode(name),
      'createdAt': FieldValue.serverTimestamp(),
      'avatar': '🧑‍💻', 'streak': 0, 'totalBlocks': 0,
    });
  }

  String _generateFriendCode(String name) {
    final prefix = name.length >= 3
        ? name.substring(0, 3).toUpperCase()
        : name.toUpperCase().padRight(3, 'X');
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(10, 13);
    return '$prefix$suffix';
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':         return 'Email tidak terdaftar';
      case 'wrong-password':         return 'Password salah';
      case 'invalid-credential':     return 'Email atau password salah';
      case 'email-already-in-use':   return 'Email sudah digunakan';
      case 'weak-password':          return 'Password minimal 6 karakter';
      case 'invalid-email':          return 'Format email tidak valid';
      case 'too-many-requests':      return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'network-request-failed': return 'Tidak ada koneksi internet';
      case 'account-exists-with-different-credential':
        return 'Email ini sudah terdaftar dengan metode login lain';
      default: return 'Terjadi kesalahan, coba lagi';
    }
  }
}
