import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/pokemon_model.dart';
import '../models/inventory_model.dart';

/// SupabaseService — menangani semua interaksi CRUD dengan Supabase.
/// Menggunakan Supabase.instance.client secara langsung.
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ════════════════════════════════════════════════════════════════
  //  AUTH — Sign Up & Sign In
  // ════════════════════════════════════════════════════════════════

  /// Mendaftarkan user baru dengan email & password.
  /// Otomatis membuat row di auth.users (Supabase Auth).
  Future<void> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      // Buat row profil di tabel public.users setelah auth berhasil
      if (response.user != null) {
        await _client.from('users').upsert({
          'id': response.user!.id,
          'pokecoin_balance': 500, // bonus awal
          'pokeball_count': 10,   // starter pack
        });
      }
    } on AuthException catch (e) {
      debugPrint('SupabaseService.signUp AuthError: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('SupabaseService.signUp error: $e');
      throw Exception('Gagal mendaftar. Silakan coba lagi.');
    }
  }

  /// Login user dengan email & password.
  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      debugPrint('SupabaseService.signIn AuthError: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('SupabaseService.signIn error: $e');
      throw Exception('Gagal login. Silakan coba lagi.');
    }
  }

  /// Logout user dari session aktif.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Mendapatkan UID user yang sedang login, atau null jika belum.
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Mengecek apakah ada session aktif.
  bool get isLoggedIn => _client.auth.currentSession != null;

  // ════════════════════════════════════════════════════════════════
  //  USER PROFILE — Read & Update
  // ════════════════════════════════════════════════════════════════

  /// Mengambil profil user dari tabel `users` berdasarkan UID.
  /// Returns null jika user belum punya profil di tabel.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('SupabaseService.getUserProfile error: $e');
      throw Exception('Gagal memuat profil user.');
    }
  }

  /// Mengupdate saldo PokéCoin dan jumlah Pokéball user.
  Future<void> updateUserCurrency(
    String uid,
    int newCoinBalance,
    int newPokeballCount,
  ) async {
    try {
      await _client.from('users').update({
        'pokecoin_balance': newCoinBalance,
        'pokeball_count': newPokeballCount,
      }).eq('id', uid);
    } catch (e) {
      debugPrint('SupabaseService.updateUserCurrency error: $e');
      throw Exception('Gagal mengupdate saldo.');
    }
  }

  /// Mengupdate tanggal klaim harian terakhir user.
  Future<void> updateLastDailyClaim(String uid, DateTime claimDate) async {
    try {
      await _client.from('users').update({
        'last_daily_claim': claimDate.toIso8601String(),
      }).eq('id', uid);
    } catch (e) {
      debugPrint('SupabaseService.updateLastDailyClaim error: $e');
      throw Exception('Gagal mengupdate klaim harian.');
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  POKEMON POOL — Read
  // ════════════════════════════════════════════════════════════════

  /// Mengambil seluruh daftar Pokémon dari tabel `pokemon_pool`.
  Future<List<PokemonModel>> getPokemonPool() async {
    try {
      final response = await _client
          .from('pokemon_pool')
          .select()
          .order('pokemon_id', ascending: true);

      return (response as List)
          .map((e) => PokemonModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getPokemonPool error: $e');
      throw Exception('Gagal memuat daftar Pokémon.');
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  INVENTORY — Read & Insert
  // ════════════════════════════════════════════════════════════════

  /// Mengambil inventory Pokémon milik user dari tabel `user_inventory`.
  Future<List<InventoryModel>> getUserInventory(String uid) async {
    try {
      final response = await _client
          .from('user_inventory')
          .select()
          .eq('user_id', uid)
          .order('obtained_at', ascending: false);

      return (response as List)
          .map((e) => InventoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getUserInventory error: $e');
      throw Exception('Gagal memuat inventory.');
    }
  }

  /// Menambahkan Pokémon hasil gacha ke inventory user.
  Future<void> addPokemonToInventory(String uid, int pokemonId) async {
    try {
      await _client.from('user_inventory').insert({
        'user_id': uid,
        'pokemon_id': pokemonId,
        'obtained_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('SupabaseService.addPokemonToInventory error: $e');
      throw Exception('Gagal menyimpan Pokémon ke inventory.');
    }
  }
}
