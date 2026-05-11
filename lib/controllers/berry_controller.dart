import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/berry_model.dart';

class BerryController {
  final Dio _dio;

  BerryController()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.pokeApiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  Future<List<BerryModel>> loadBerries() async {
    try {
      final berryResponse = await _dio.get('/berry?limit=64');
      final berriesRaw = berryResponse.data['results'] as List;

      return berriesRaw.map((e) {
        final url = e['url'] as String;
        final segments = url.split('/').where((s) => s.isNotEmpty).toList();
        final id = int.parse(segments.last);
        return BerryModel(
          id: id,
          name: e['name'] as String,
          itemName: '${e['name']}-berry',
          growthTime: 0,
          size: 0,
          spriteUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${e['name']}-berry.png',
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat berries: $e');
    }
  }

  List<BerryModel> filterBerries(List<BerryModel> berries, String query) {
    if (query.isEmpty) return List.from(berries);
    final lowerQuery = query.toLowerCase();
    return berries.where((berry) {
      return berry.name.toLowerCase().contains(lowerQuery) ||
          berry.id.toString().contains(lowerQuery);
    }).toList();
  }

  List<BerryModel> sortBerries(List<BerryModel> berries, String sortType) {
    final sorted = List<BerryModel>.from(berries);
    switch (sortType) {
      case 'az':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'za':
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'id':
      default:
        sorted.sort((a, b) => a.id.compareTo(b.id));
        break;
    }
    return sorted;
  }
}
