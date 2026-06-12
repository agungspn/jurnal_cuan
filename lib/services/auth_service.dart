import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk listen perubahan state login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cek apakah user sudah login
  User? get currentUser => _auth.currentUser;

  // Login dengan email & password
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential;
  }

  // Daftar akun baru
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Pesan error Firebase yang lebih ramah
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan. Coba daftar dulu ya.';
      case 'wrong-password':
        return 'Password salah. Coba lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Coba login.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
