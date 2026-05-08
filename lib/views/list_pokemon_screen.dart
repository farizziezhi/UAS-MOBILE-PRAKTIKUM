import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../controllers/pokemon_list_controller.dart';
import 'detail_screen.dart';

/// ListPokemonScreen — menampilkan list 151 Pokémon Gen 1 dari PokeAPI.
class ListPokemonScreen extends StatefulWidget {
  const ListPokemonScreen({super.key});

  @override
  State<ListPokemonScreen> createState() => _ListPokemonScreenState();
}

class _ListPokemonScreenState extends State<ListPokemonScreen> {
  final _controller = PokemonListController();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _allPokemon = [];
  List<Map<String, dynamic>> _filteredPokemon = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isGrid = false;
  String _sortType = 'id';

  @override
  void initState() {
    super.initState();
    _loadPokemonList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPokemonList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _controller.fetchPokemonList();
      setState(() {
        _allPokemon = list;
        _filteredPokemon = _controller.sortPokemon(list, _sortType);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _onSearchChanged() {
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    final filtered = _controller.filterPokemon(_allPokemon, _searchController.text);
    setState(() {
      _filteredPokemon = _controller.sortPokemon(filtered, _sortType);
    });
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
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGrid = !_isGrid),
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            tooltip: _isGrid ? 'Tampilan List' : 'Tampilan Grid',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadPokemonList,
                        child: _isGrid ? _buildGrid() : _buildList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // ── Search Field ──
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.greyMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.greyMedium),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.greyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Sort Button ──
          PopupMenuButton<String>(
            onSelected: (value) {
              _sortType = value;
              _applyFilterAndSort();
            },
            tooltip: 'Urutkan',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              _buildSortMenuItem('id', Icons.tag, 'Nomor (Default)'),
              _buildSortMenuItem('az', Icons.sort_by_alpha, 'A → Z'),
              _buildSortMenuItem('za', Icons.sort_by_alpha, 'Z → A'),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _sortType != 'id' ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Icon(
                Icons.sort,
                color: _sortType != 'id' ? Colors.white : AppColors.greyMedium,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, IconData icon, String label) {
    final isActive = _sortType == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: isActive ? AppColors.primary : AppColors.greyMedium),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (isActive) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16, color: AppColors.primary),
          ],
        ],
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

  Widget _buildList() {
    if (_filteredPokemon.isEmpty) return _buildEmptySearch();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredPokemon.length,
      itemBuilder: (context, index) =>
          _buildPokemonTile(_filteredPokemon[index]),
    );
  }

  Widget _buildGrid() {
    if (_filteredPokemon.isEmpty) return _buildEmptySearch();
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredPokemon.length,
      itemBuilder: (context, index) =>
          _buildPokemonCard(_filteredPokemon[index]),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.greyMedium),
          const SizedBox(height: 16),
          Text(
            'Pokémon "${_searchController.text}" tidak ditemukan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTile(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final name = item['name'] as String;
    final spriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(pokemonId: id)),
      ),
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
            CachedNetworkImage(
              imageUrl: spriteUrl,
              width: 56,
              height: 56,
              placeholder: (_, __) => const SizedBox(
                width: 56,
                height: 56,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 40,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name[0].toUpperCase() + name.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '#${id.toString().padLeft(3, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.greyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonCard(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final name = item['name'] as String;
    final spriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(pokemonId: id)),
      ),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: spriteUrl,
              width: 72,
              height: 72,
              placeholder: (_, __) => const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 48,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name[0].toUpperCase() + name.substring(1),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '#${id.toString().padLeft(3, '0')}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
