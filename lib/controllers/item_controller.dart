import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/item_model.dart';
import '../models/berry_model.dart';

class ItemController {
  final Dio _dio;

  ItemController()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.pokeApiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<List<ItemModel>> loadItems() async {
    try {
      final itemResponse = await _dio.get('/item?limit=16');
      final itemsRaw = itemResponse.data['results'] as List;

      return itemsRaw.map((e) {
        final url = e['url'] as String;
        final segments = url.split('/').where((s) => s.isNotEmpty).toList();
        final id = int.parse(segments.last);
        return ItemModel(
          id: id,
          name: e['name'] as String,
          cost: 0,
          spriteUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${e['name']}.png',
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat item: $e');
    }
  }

  List<ItemModel> filterItems(List<ItemModel> items, String query) {
    if (query.isEmpty) return List.from(items);
    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.id.toString().contains(lowerQuery);
    }).toList();
  }

  List<ItemModel> sortItems(List<ItemModel> items, String sortType) {
    final sorted = List<ItemModel>.from(items);
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
