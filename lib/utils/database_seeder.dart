import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DatabaseSeeder — mengisi tabel `pokemon_pool` di Supabase
/// dengan 151 Pokémon Gen 1 dari PokeAPI.
class DatabaseSeeder {
  /// Pokémon legendaris Gen 1 (ditentukan manual berdasarkan lore).
  static const List<int> _legendaryIds = [
    144, // Articuno
    145, // Zapdos
    146, // Moltres
    150, // Mewtwo
    151, // Mew
  ];

  /// Pokémon epic Gen 1 (pseudo-legendary, starter akhir, langka).
  static const List<int> _epicIds = [
    3,   // Venusaur
    6,   // Charizard
    9,   // Blastoise
    26,  // Raichu
    38,  // Ninetales
    59,  // Arcanine
    65,  // Alakazam
    68,  // Machamp
    76,  // Golem
    94,  // Gengar
    103, // Exeggutor
    112, // Rhydon
    130, // Gyarados
    131, // Lapras
    134, // Vaporeon
    135, // Jolteon
    136, // Flareon
    143, // Snorlax
    149, // Dragonite
  ];

  /// Pokémon rare Gen 1 (evolusi tengah, semi-langka).
  static const List<int> _rareIds = [
    2,   // Ivysaur
    5,   // Charmeleon
    8,   // Wartortle
    24,  // Arbok
    25,  // Pikachu
    28,  // Sandslash
    31,  // Nidoqueen
    34,  // Nidoking
    36,  // Clefable
    40,  // Wigglytuff
    45,  // Vileplume
    47,  // Parasect
    49,  // Venomoth
    51,  // Dugtrio
    53,  // Persian
    55,  // Golduck
    57,  // Primeape
    62,  // Poliwrath
    64,  // Kadabra
    67,  // Machoke
    71,  // Victreebel
    73,  // Tentacruel
    75,  // Graveler
    78,  // Rapidash
    80,  // Slowbro
    82,  // Magneton
    85,  // Dodrio
    87,  // Dewgong
    89,  // Muk
    91,  // Cloyster
    97,  // Hypno
    99,  // Kingler
    101, // Electrode
    105, // Marowak
    106, // Hitmonlee
    107, // Hitmonchan
    110, // Weezing
    113, // Chansey
    115, // Kangaskhan
    117, // Seadra
    119, // Seaking
    121, // Starmie
    122, // Mr. Mime
    123, // Scyther
    124, // Jynx
    125, // Electabuzz
    126, // Magmar
    127, // Pinsir
    128, // Tauros
    139, // Omastar
    141, // Kabutops
    142, // Aerodactyl
    148, // Dragonair
  ];

  /// Seed 151 Pokémon Gen 1 ke tabel `pokemon_pool`.
  ///
  /// Alur:
  /// 1. GET /pokemon?limit=151 dari PokeAPI
  /// 2. Parse nama & ID dari response
  /// 3. Tentukan rarity & drop_weight
  /// 4. Upsert ke Supabase
  static Future<void> seedPokemonPool() async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🌱 DATABASE SEEDER — Memulai seed Pokemon Pool');
    debugPrint('═══════════════════════════════════════════');

    try {
      // ── 1. Ambil data 151 Pokémon dari PokeAPI ──
      debugPrint('\n📡 Mengambil data dari PokeAPI...');
      final response = await dio.get(
        'https://pokeapi.co/api/v2/pokemon?limit=151',
      );

      final results = response.data['results'] as List;
      debugPrint('✅ Berhasil mengambil ${results.length} Pokémon dari PokeAPI\n');

      // ── 2. Parse dan tentukan rarity ──
      final List<Map<String, dynamic>> dataList = [];
      int countCommon = 0, countRare = 0, countEpic = 0, countLegendary = 0;

      for (final entry in results) {
        final name = entry['name'] as String;
        final url = entry['url'] as String;

        // Ekstrak pokemon_id dari URL (misal: .../pokemon/25/ → 25)
        final segments = url.split('/').where((s) => s.isNotEmpty).toList();
        final pokemonId = int.parse(segments.last);

        // Tentukan rarity berdasarkan ID
        String rarity;
        int dropWeight;

        if (_legendaryIds.contains(pokemonId)) {
          rarity = 'legendary';
          dropWeight = 5;
          countLegendary++;
        } else if (_epicIds.contains(pokemonId)) {
          rarity = 'epic';
          dropWeight = 15;
          countEpic++;
        } else if (_rareIds.contains(pokemonId)) {
          rarity = 'rare';
          dropWeight = 30;
          countRare++;
        } else {
          rarity = 'common';
          dropWeight = 50;
          countCommon++;
        }

        dataList.add({
          'pokemon_id': pokemonId,
          'name': name,
          'rarity': rarity,
          'drop_weight': dropWeight,
        });

        // Log setiap 10 Pokémon
        if (pokemonId % 10 == 0 || pokemonId <= 3) {
          debugPrint('  #${pokemonId.toString().padLeft(3, '0')} '
              '${name.padRight(14)} → $rarity (weight: $dropWeight)');
        }
      }

      // ── 3. Statistik rarity ──
      debugPrint('\n📊 Distribusi Rarity:');
      debugPrint('  Common    : $countCommon Pokémon (weight 50)');
      debugPrint('  Rare      : $countRare Pokémon (weight 30)');
      debugPrint('  Epic      : $countEpic Pokémon (weight 15)');
      debugPrint('  Legendary : $countLegendary Pokémon (weight 5)');
      debugPrint('  Total     : ${dataList.length} Pokémon');

      // ── 4. Upsert ke Supabase ──
      debugPrint('\n💾 Mengupload ke Supabase (upsert)...');
      await Supabase.instance.client
          .from('pokemon_pool')
          .upsert(dataList, onConflict: 'pokemon_id');

      debugPrint('✅ Berhasil seed ${dataList.length} Pokémon ke tabel pokemon_pool!');
      debugPrint('\n═══════════════════════════════════════════');
      debugPrint('🎉 SEEDER SELESAI!');
      debugPrint('═══════════════════════════════════════════');
    } on DioException catch (e) {
      debugPrint('❌ DioError: ${e.type} - ${e.message}');
      throw Exception('Gagal mengambil data dari PokeAPI: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw Exception('Gagal menjalankan seeder: $e');
    }
  }
}
