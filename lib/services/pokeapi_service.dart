import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pokemon_detail_model.dart';
import '../models/item_model.dart';
import '../models/berry_model.dart';
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
}
