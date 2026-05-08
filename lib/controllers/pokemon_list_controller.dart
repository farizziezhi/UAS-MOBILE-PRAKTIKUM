import 'package:dio/dio.dart';
import '../utils/constants.dart';

/// PokemonListController — logika fetch dan filter daftar Pokémon dari PokeAPI.
class PokemonListController {
  final Dio _dio;

  PokemonListController()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.pokeApiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Mengambil 151 Pokémon Gen 1 dari PokeAPI.
  /// Returns List of Map berisi 'id' dan 'name'.
  Future<List<Map<String, dynamic>>> fetchPokemonList() async {
    try {
      final response = await _dio.get('/pokemon?limit=151');
      final results = response.data['results'] as List;

      return results.map((e) {
        final url = e['url'] as String;
        final segments = url.split('/').where((s) => s.isNotEmpty).toList();
        final id = int.parse(segments.last);
        return {'id': id, 'name': e['name'] as String};
      }).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response != null
            ? 'Gagal memuat data (HTTP ${e.response?.statusCode})'
            : 'Tidak dapat terhubung ke PokeAPI. Periksa koneksi internet.',
      );
    } catch (e) {
      throw Exception('Gagal memuat daftar Pokémon.');
    }
  }

  /// Filter list Pokémon berdasarkan keyword (nama atau nomor ID).
  /// Pencarian tidak case-sensitive.
  List<Map<String, dynamic>> filterPokemon(
    List<Map<String, dynamic>> allPokemon,
    String keyword,
  ) {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return allPokemon;

    return allPokemon.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final id = (p['id'] as int).toString();
      return name.contains(query) || id.contains(query);
    }).toList();
  }
}
