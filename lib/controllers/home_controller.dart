import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/inventory_model.dart';

/// HomeController — mengambil dan menyiapkan data untuk beranda.
/// Memanggil SupabaseService secara paralel dengan Future.wait.
class HomeController {
  final SupabaseService _supabaseService;

  HomeController({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Memuat semua data yang dibutuhkan beranda secara bersamaan.
  ///
  /// Returns Map berisi:
  /// - `'user'`      : [UserModel?] profil user
  /// - `'inventory'` : [List<InventoryModel>] koleksi Pokémon user
  ///
  /// Throws [Exception] jika gagal memuat data.
  Future<Map<String, dynamic>> loadHomeData(String uid) async {
    try {
      // Jalankan kedua query secara paralel untuk performa optimal
      final results = await Future.wait([
        _supabaseService.getUserProfile(uid),
        _supabaseService.getUserInventory(uid),
      ]);

      final UserModel? user = results[0] as UserModel?;
      final List<InventoryModel> inventory =
          results[1] as List<InventoryModel>;

      return {
        'user': user,
        'inventory': inventory,
      };
    } catch (e) {
      throw Exception('Gagal memuat data beranda: $e');
    }
  }

  /// Klaim hadiah harian: +5 Pokéball.
  /// Mengecek apakah user sudah klaim hari ini.
  ///
  /// Returns Map berisi:
  /// - `'success'` : [bool]
  /// - `'message'` : [String] pesan untuk ditampilkan
  /// - `'user'`    : [UserModel?] profil user terbaru
  Future<Map<String, dynamic>> claimDaily(String uid) async {
    try {
      final user = await _supabaseService.getUserProfile(uid);
      if (user == null) throw Exception('User tidak ditemukan.');

      final now = DateTime.now();
      final lastClaim = user.lastDailyClaim;

      // Cek apakah sudah klaim hari ini
      if (lastClaim != null &&
          now.year == lastClaim.year &&
          now.month == lastClaim.month &&
          now.day == lastClaim.day) {
        return {
          'success': false,
          'message': 'Kamu sudah klaim hari ini. Kembali besok!',
          'user': user,
        };
      }

      // Berikan +5 Pokéball dan update last_daily_claim
      final newBallCount = user.pokeballCount + 5;
      await _supabaseService.updateUserCurrency(
        uid,
        user.pokecoinBalance,
        newBallCount,
      );

      // Update last_daily_claim secara terpisah
      await _supabaseService.updateLastDailyClaim(uid, now);

      final updatedUser = user.copyWith(
        pokeballCount: newBallCount,
        lastDailyClaim: now,
      );

      return {
        'success': true,
        'message': 'Klaim berhasil! +5 Pokéball 🎉',
        'user': updatedUser,
      };
    } catch (e) {
      throw Exception('Gagal klaim harian: $e');
    }
  }
}
