import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pokemon_detail_model.dart';
import '../models/item_model.dart';
import '../models/item_detail_model.dart';
import '../models/berry_model.dart';
import '../models/berry_detail_model.dart';
import '../utils/constants.dart';

/// PokeapiService — menangani semua HTTP request ke PokeAPI v2.
/// Menggunakan Dio sebagai HTTP client.
class PokeapiService {
  final Dio _dio;

  PokeapiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.pokeApiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
          ),
        );

  /// Mengambil detail Pokémon berdasarkan ID dari PokeAPI.
  ///
  /// Endpoint: GET /pokemon/{pokemonId}
  /// Returns: [PokemonDetailModel] yang sudah di-parse dari JSON.
  /// Throws: [Exception] jika request gagal.
  Future<PokemonDetailModel> getPokemonDetail(int pokemonId) async {
    try {
      final response = await _dio.get('/pokemon/$pokemonId');
      return PokemonDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('PokeapiService.getPokemonDetail($pokemonId) DioError: '
          '${e.type} - ${e.message}');

      if (e.response != null) {
        throw Exception(
          'Gagal mengambil data Pokémon #$pokemonId '
          '(HTTP ${e.response?.statusCode})',
        );
      } else {
        throw Exception(
          'Tidak dapat terhubung ke PokeAPI. Periksa koneksi internet.',
        );
      }
    } catch (e) {
      debugPrint('PokeapiService.getPokemonDetail($pokemonId) error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data Pokémon #$pokemonId');
    }
  }

  /// Mengambil detail Item berdasarkan nama dari PokeAPI.
  Future<ItemModel> getItem(String name) async {
    try {
      final response = await _dio.get('/item/$name');
      return ItemModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('PokeapiService.getItem($name) DioError: ${e.type} - ${e.message}');
      throw Exception('Gagal mengambil data Item $name');
    } catch (e) {
      debugPrint('PokeapiService.getItem($name) error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data Item $name');
    }
  }

  /// Mengambil detail Berry berdasarkan nama dari PokeAPI.
  Future<BerryModel> getBerry(String name) async {
    try {
      final response = await _dio.get('/berry/$name');
      return BerryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('PokeapiService.getBerry($name) DioError: ${e.type} - ${e.message}');
      throw Exception('Gagal mengambil data Berry $name');
    } catch (e) {
      debugPrint('PokeapiService.getBerry($name) error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data Berry $name');
    }
  }

  /// Mengambil detail lengkap Item/Pokéball berdasarkan ID dari PokeAPI.
  ///
  /// Endpoint: GET /item/{itemId}
  ///
  /// Parse data: category, attributes, effect_entries, flavor_text_entries,
  /// fling_power, dan sprites.
  ///
  /// Returns: [ItemDetailModel] dengan data lengkap.
  /// Throws: [Exception] jika request gagal.
  Future<ItemDetailModel> getItemDetail(int itemId) async {
    try {
      final response = await _dio.get('/item/$itemId');
      final data = response.data as Map<String, dynamic>;

      // ── Parse category ──
      final categoryData = data['category'] as Map<String, dynamic>?;
      final category = categoryData?['name'] as String? ?? 'unknown';

      // ── Parse fling_power ──
      final flingPower = data['fling_power'] as int? ?? 0;

      // ── Parse attributes ──
      final attributesRaw = data['attributes'] as List<dynamic>? ?? [];
      final attributes = attributesRaw
          .map((attr) => (attr as Map<String, dynamic>)['name'] as String)
          .toList();

      // ── Parse effect_entries (bahasa Inggris) ──
      String? effectDescription;
      final effectEntries = data['effect_entries'] as List<dynamic>? ?? [];
      for (var entry in effectEntries) {
        final lang = (entry as Map<String, dynamic>)['language']['name'];
        if (lang == 'en') {
          effectDescription = entry['effect'] as String?;
          break;
        }
      }

      // ── Parse flavor_text_entries (bahasa Inggris) ──
      final flavorTextsRaw = data['flavor_text_entries'] as List<dynamic>? ?? [];
      final flavorTextEntries = <String>[];
      for (var entry in flavorTextsRaw) {
        final lang = (entry as Map<String, dynamic>)['language']['name'];
        if (lang == 'en') {
          final text = (entry['text'] as String?)
              ?.replaceAll('\n', ' ')
              .replaceAll('\f', ' ')
              .trim();
          if (text != null && text.isNotEmpty && !flavorTextEntries.contains(text)) {
            flavorTextEntries.add(text);
          }
        }
      }

      // ── Parse sprite ──
      final spriteUrl =
          (data['sprites'] as Map<String, dynamic>?)?['default'] as String? ?? '';

      return ItemDetailModel(
        id: data['id'] as int,
        name: data['name'] as String,
        cost: data['cost'] as int? ?? 0,
        spriteUrl: spriteUrl,
        category: category,
        flingPower: flingPower,
        effectDescription: effectDescription,
        attributes: attributes,
        flavorTextEntries: flavorTextEntries,
      );
    } on DioException catch (e) {
      debugPrint(
        'PokeapiService.getItemDetail($itemId) DioError: '
        '${e.type} - ${e.message}',
      );

      if (e.response != null) {
        throw Exception(
          'Gagal mengambil data Item #$itemId '
          '(HTTP ${e.response?.statusCode})',
        );
      } else {
        throw Exception(
          'Tidak dapat terhubung ke PokeAPI. Periksa koneksi internet.',
        );
      }
    } catch (e) {
      debugPrint('PokeapiService.getItemDetail($itemId) error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data Item #$itemId');
    }
  }

  /// Mengambil detail Berry dengan hybrid fetch dari Berry + Item endpoint.
  ///
  /// Hybrid Fetch:
  /// 1. Endpoint: GET /berry/{berryId} → ambil data berry dan URL item
  /// 2. Endpoint: GET item/{itemId} dari URL yang didapat
  /// 3. Gabungkan data keduanya ke [BerryDetailModel]
  ///
  /// Returns: [BerryDetailModel] dengan data lengkap dari kedua endpoint.
  /// Throws: [Exception] jika salah satu request gagal.
  Future<BerryDetailModel> getBerryDetail(int berryId) async {
    try {
      // ── Fetch pertama: Data Berry ──
      final berryResponse = await _dio.get('/berry/$berryId');
      final berryData = berryResponse.data as Map<String, dynamic>;

      // ── Extract URL Item dari Berry response ──
      final itemUrl = berryData['item']['url'] as String?;
      if (itemUrl == null) {
        throw Exception('URL item tidak ditemukan di response Berry');
      }

      // ── Fetch kedua: Data Item (extract ID dari URL) ──
      final itemId = _extractIdFromUrl(itemUrl);
      final itemResponse = await _dio.get('/item/$itemId');
      final itemData = itemResponse.data as Map<String, dynamic>;

      // ── Parse effect dari item.effect_entries (bahasa Inggris) ──
      String? effectDescription;
      final effectEntries = itemData['effect_entries'] as List<dynamic>?;
      if (effectEntries != null) {
        for (var entry in effectEntries) {
          final lang = (entry as Map<String, dynamic>)['language']['name'];
          if (lang == 'en') {
            effectDescription = entry['effect'] as String?;
            break;
          }
        }
      }

      // ── Gabungkan data ──
      return BerryDetailModel(
        id: berryData['id'] as int,
        name: berryData['name'] as String,
        size: berryData['size'] as int,
        growthTime: berryData['growth_time'] as int,
        maxHarvest: berryData['max_harvest'] as int,
        cost: itemData['cost'] as int? ?? 0,
        spriteUrl:
            (itemData['sprites'] as Map<String, dynamic>?)?['default']
                as String? ??
            '',
        effectDescription: effectDescription,
        flavors: _parseFlavors(berryData['flavors'] as List<dynamic>? ?? []),
      );
    } on DioException catch (e) {
      debugPrint(
        'PokeapiService.getBerryDetail($berryId) DioError: '
        '${e.type} - ${e.message}',
      );

      if (e.response != null) {
        throw Exception(
          'Gagal mengambil data Berry #$berryId '
          '(HTTP ${e.response?.statusCode})',
        );
      } else {
        throw Exception(
          'Tidak dapat terhubung ke PokeAPI. Periksa koneksi internet.',
        );
      }
    } catch (e) {
      debugPrint('PokeapiService.getBerryDetail($berryId) error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data Berry #$berryId');
    }
  }

  /// Helper: Extract ID dari PokeAPI URL
  /// Contoh: https://pokeapi.co/api/v2/item/123/ → 123
  static int _extractIdFromUrl(String url) {
    final parts = url.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      final lastPart = parts.last;
      final id = int.tryParse(lastPart);
      if (id != null) return id;
    }
    throw Exception('Tidak bisa extract ID dari URL: $url');
  }

  /// Helper: Parse flavors dari array PokeAPI Berry JSON
  static Map<String, int> _parseFlavors(List<dynamic> flavors) {
    final Map<String, int> result = {};
    for (var item in flavors) {
      final flavorName =
          (item as Map<String, dynamic>)['flavor']['name'] as String;
      final potency = item['potency'] as int;
      result[flavorName] = potency;
    }
    return result;
  }
}

