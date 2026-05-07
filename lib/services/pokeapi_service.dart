import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pokemon_detail_model.dart';
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
}
