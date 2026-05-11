import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../controllers/item_controller.dart';
import '../controllers/berry_controller.dart';
import '../models/item_model.dart';
import '../models/berry_model.dart';
import 'widgets_item/item_tab_view.dart';
import 'widgets_item/berry_tab_view.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ItemController _itemController = ItemController();
  final BerryController _berryController = BerryController();
  final _searchController = TextEditingController();

  List<ItemModel> _allItems = [];
  List<ItemModel> _filteredItems = [];

  List<BerryModel> _allBerries = [];
  List<BerryModel> _filteredBerries = [];

  bool _isLoading = true;
  String? _errorMessage;
  bool _isGrid = false;
  String _sortType = 'id';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _applyFilterAndSort();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _itemController.loadItems();
      final berries = await _berryController.loadBerries();

      setState(() {
        _allItems = items;
        _allBerries = berries;
        _applyFilterAndSort();
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
    final query = _searchController.text;

    final filteredItems = _itemController.filterItems(_allItems, query);
    final filteredBerries = _berryController.filterBerries(_allBerries, query);

    setState(() {
      _filteredItems = _itemController.sortItems(filteredItems, _sortType);
      _filteredBerries = _berryController.sortBerries(
        filteredBerries,
        _sortType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Items & Berries',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGrid = !_isGrid),
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            tooltip: _isGrid ? 'Tampilan List' : 'Tampilan Grid',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textWhite,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pokéballs', icon: Icon(Icons.catching_pokemon)),
            Tab(text: 'Berries', icon: Icon(Icons.eco)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ItemTabView(
                        items: _filteredItems,
                        isGrid: _isGrid,
                        onRefresh: _loadData,
                        searchQuery: _searchController.text,
                      ),
                      BerryTabView(
                        berries: _filteredBerries,
                        isGrid: _isGrid,
                        onRefresh: _loadData,
                        searchQuery: _searchController.text,
                      ),
                    ],
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
                hintText: 'Cari nama atau ID...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.greyMedium,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.greyMedium,
                        ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              _buildSortMenuItem('id', Icons.tag, 'ID (Default)'),
              _buildSortMenuItem('az', Icons.sort_by_alpha, 'A → Z'),
              _buildSortMenuItem('za', Icons.sort_by_alpha, 'Z → A'),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _sortType != 'id'
                    ? AppColors.primary
                    : AppColors.surface,
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

  PopupMenuItem<String> _buildSortMenuItem(
    String value,
    IconData icon,
    String label,
  ) {
    final isActive = _sortType == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.primary : AppColors.greyMedium,
          ),
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
            'Oops! Gagal memuat data.\n$_errorMessage',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
