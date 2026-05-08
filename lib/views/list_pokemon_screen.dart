import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'detail_screen.dart';

/// ListPokemonScreen — menampilkan list 151 Pokémon Gen 1 dari PokeAPI.
class ListPokemonScreen extends StatefulWidget {
  const ListPokemonScreen({super.key});

  @override
  State<ListPokemonScreen> createState() => _ListPokemonScreenState();
}

class _ListPokemonScreenState extends State<ListPokemonScreen> {
  final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.pokeApiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  List<_PokemonListItem> _pokemonList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPokemonList();
  }

  Future<void> _loadPokemonList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get('/pokemon?limit=151');
      final results = response.data['results'] as List;

      final list = results.map((e) {
        final url = e['url'] as String;
        final segments = url.split('/').where((s) => s.isNotEmpty).toList();
        final id = int.parse(segments.last);
        return _PokemonListItem(id: id, name: e['name'] as String);
      }).toList();

      setState(() {
        _pokemonList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat daftar Pokémon. Periksa koneksi internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daftar Pokémon',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadPokemonList,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _pokemonList.length,
                    itemBuilder: (context, index) {
                      return _buildPokemonTile(_pokemonList[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPokemonList,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTile(_PokemonListItem item) {
    final spriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${item.id}.png';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(pokemonId: item.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Sprite ──
            CachedNetworkImage(
              imageUrl: spriteUrl,
              width: 56,
              height: 56,
              placeholder: (_, __) => const SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 40,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(width: 16),

            // ── Nama & ID ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name[0].toUpperCase() + item.name.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '#${item.id.toString().padLeft(3, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Arrow ──
            const Icon(Icons.chevron_right, color: AppColors.greyMedium),
          ],
        ),
      ),
    );
  }
}

class _PokemonListItem {
  final int id;
  final String name;
  const _PokemonListItem({required this.id, required this.name});
}
