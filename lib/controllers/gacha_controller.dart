import 'dart:math';
import '../services/supabase_service.dart';
import '../models/pokemon_model.dart';

/// GachaController — logika inti sistem gacha dengan weighted RNG.
///
/// Alur rollGacha:
/// 1. Cek Pokéball user > 0
/// 2. Ambil pokemon_pool, lakukan weighted random
/// 3. Cek duplikat di inventory
/// 4. Jika duplikat → konversi ke PokéCoin
/// 5. Jika baru → tambahkan ke inventory
/// 6. Return hasil gacha sebagai Map untuk UI
class GachaController {
  final SupabaseService _supabaseService;
  final Random _random = Random();

  GachaController({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Tabel konversi duplikat → PokéCoin berdasarkan rarity.
  static const Map<String, int> _duplicateCoinReward = {
    'common': 10,
    'rare': 50,
    'epic': 150,
    'legendary': 500,
  };

  /// Menjalankan 1x gacha roll.
  ///
  /// Returns Map berisi:
  /// - `'pokemon'`       : [PokemonModel] Pokémon yang didapat
  /// - `'isDuplicate'`   : [bool] apakah duplikat
  /// - `'coinReward'`    : [int] koin kompensasi (0 jika bukan duplikat)
  /// - `'newCoinBalance'`: [int] saldo koin terbaru
  /// - `'newBallCount'`  : [int] jumlah ball terbaru
  ///
  /// Throws [Exception] jika Pokéball habis atau terjadi error.
  Future<Map<String, dynamic>> rollGacha(String uid) async {
    try {
      // ── 1. Cek Pokéball user ──
      final user = await _supabaseService.getUserProfile(uid);
      if (user == null) throw Exception('User tidak ditemukan.');
      if (user.pokeballCount <= 0) {
        throw Exception('Pokéball habis! Beli di Shop atau klaim Daily.');
      }

      // ── 2. Ambil pokemon pool ──
      final pool = await _supabaseService.getPokemonPool();
      if (pool.isEmpty) {
        throw Exception('Pokemon pool kosong. Hubungi admin.');
      }

      // ── 3. Weighted RNG ──
      final selectedPokemon = _weightedRandom(pool);

      // ── 4. Cek duplikat di inventory ──
      final inventory = await _supabaseService.getUserInventory(uid);
      final isDuplicate = inventory.any(
        (item) => item.pokemonId == selectedPokemon.pokemonId,
      );

      int coinReward = 0;
      int newCoinBalance = user.pokecoinBalance;
      final int newBallCount = user.pokeballCount - 1;

      if (isDuplicate) {
        // ── 5a. DUPLIKAT → Konversi ke PokéCoin ──
        coinReward = _duplicateCoinReward[selectedPokemon.rarity] ?? 10;
        newCoinBalance += coinReward;

        await _supabaseService.updateUserCurrency(
          uid,
          newCoinBalance,
          newBallCount,
        );
      } else {
        // ── 5b. BARU → Tambah ke inventory ──
        await _supabaseService.addPokemonToInventory(
          uid,
          selectedPokemon.pokemonId,
        );

        await _supabaseService.updateUserCurrency(
          uid,
          newCoinBalance,
          newBallCount,
        );
      }

      // ── 6. Return hasil gacha untuk UI ──
      return {
        'pokemon': selectedPokemon,
        'isDuplicate': isDuplicate,
        'coinReward': coinReward,
        'newCoinBalance': newCoinBalance,
        'newBallCount': newBallCount,
      };
    } catch (e) {
      throw Exception('Gagal melakukan gacha: $e');
    }
  }

  /// Weighted Random Selection.
  ///
  /// Contoh: 3 Pokémon dengan weight [30, 15, 5] → total = 50.
  /// Random(0..49): 0-29 → Pokémon A, 30-44 → Pokémon B, 45-49 → Pokémon C.
  PokemonModel _weightedRandom(List<PokemonModel> pool) {
    // Hitung total weight
    final totalWeight = pool.fold<int>(0, (sum, p) => sum + p.dropWeight);

    // Pilih angka random dari 0 sampai totalWeight - 1
    int roll = _random.nextInt(totalWeight);

    // Tentukan Pokémon yang terpilih
    for (final pokemon in pool) {
      roll -= pokemon.dropWeight;
      if (roll < 0) return pokemon;
    }

    // Fallback (seharusnya tidak pernah tercapai)
    return pool.last;
  }
}
