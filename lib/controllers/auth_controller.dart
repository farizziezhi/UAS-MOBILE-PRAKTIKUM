import '../services/supabase_service.dart';

/// AuthController — menangani logika autentikasi (login & register).
/// Meneruskan panggilan ke SupabaseService dan melempar Exception jika gagal.
class AuthController {
  final SupabaseService _supabaseService;

  AuthController({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Login user dengan email & password.
  /// Throws [Exception] jika gagal.
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email dan password tidak boleh kosong.');
    }
    await _supabaseService.signIn(email.trim(), password);
  }

  /// Register user baru dengan email & password.
  /// Otomatis membuat profil awal (500 coin, 10 ball) di tabel users.
  /// Throws [Exception] jika gagal.
  Future<void> register(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email dan password tidak boleh kosong.');
    }
    if (password.length < 6) {
      throw Exception('Password minimal 6 karakter.');
    }
    await _supabaseService.signUp(email.trim(), password);
  }

  /// Logout user dari session aktif.
  Future<void> logout() async {
    await _supabaseService.signOut();
  }

  /// Cek apakah user sedang login.
  bool get isLoggedIn => _supabaseService.isLoggedIn;

  /// Mendapatkan UID user yang sedang login.
  String? get currentUserId => _supabaseService.currentUserId;
}
