import '../services/supabase_service.dart';

/// ShopController — logika pembelian Pokéball dengan PokéCoin.
class ShopController {
  final SupabaseService _supabaseService;

  ShopController({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Membeli Pokéball dengan PokéCoin.
  ///
  /// [uid]    : User ID
  /// [price]  : Total harga dalam PokéCoin
  /// [amount] : Jumlah Pokéball yang dibeli
  ///
  /// Throws [Exception] jika koin tidak cukup atau gagal update.
  Future<void> buyPokeball(String uid, int price, int amount) async {
    try {
      // 1. Ambil data user terkini
      final user = await _supabaseService.getUserProfile(uid);
      if (user == null) throw Exception('User tidak ditemukan.');

      // 2. Cek apakah koin cukup
      if (user.pokecoinBalance < price) {
        throw Exception(
          'Koin tidak cukup! Butuh $price, saldo kamu ${user.pokecoinBalance}.',
        );
      }

      // 3. Hitung saldo baru
      final newCoinBalance = user.pokecoinBalance - price;
      final newBallCount = user.pokeballCount + amount;

      // 4. Update ke Supabase
      await _supabaseService.updateUserCurrency(
        uid,
        newCoinBalance,
        newBallCount,
      );
    } catch (e) {
      throw Exception('Gagal membeli Pokéball: $e');
    }
  }
}
