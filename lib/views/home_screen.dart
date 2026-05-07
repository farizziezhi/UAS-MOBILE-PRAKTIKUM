import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../controllers/home_controller.dart';
import '../models/user_model.dart';
import '../models/inventory_model.dart';
import 'gacha_screen.dart';
import 'detail_screen.dart';

/// HomeScreen — halaman utama menampilkan koleksi Pokémon user.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeController = HomeController();

  UserModel? _user;
  List<InventoryModel> _inventory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final data = await _homeController.loadHomeData(uid);

      // setState: simpan data dari controller ke state lokal
      setState(() {
        _user = data['user'] as UserModel?;
        _inventory = data['inventory'] as List<InventoryModel>;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _handleClaimDaily() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final result = await _homeController.claimDaily(uid);

      if (!mounted) return;

      // setState: update data user setelah klaim
      setState(() {
        _user = result['user'] as UserModel?;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor:
              (result['success'] as bool) ? AppColors.success : AppColors.gold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pokédex Gacha',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Tombol Daily Claim
          IconButton(
            onPressed: _handleClaimDaily,
            icon: const Icon(Icons.card_giftcard),
            tooltip: 'Klaim Harian',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),

      // ── FAB Gacha ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigasi ke GachaScreen, refresh data saat kembali
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GachaScreen()),
          );
          _loadData(); // Refresh setelah gacha
        },
        backgroundColor: AppColors.pokeBallRed,
        icon: const Icon(Icons.catching_pokemon, color: Colors.white),
        label: Text(
          'Gacha!',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // ── Balance Banner ──
          _buildBalanceBanner(),

          // ── Inventory Grid ──
          Expanded(
            child: _inventory.isEmpty
                ? _buildEmptyState()
                : _buildInventoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pokeBallRed.withValues(alpha: 0.1),
            AppColors.gold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // PokéCoin
          Row(
            children: [
              const Icon(Icons.monetization_on, color: AppColors.gold, size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PokéCoin',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_user?.pokecoinBalance ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: AppColors.greyLight,
          ),

          // Pokéball
          Row(
            children: [
              const Icon(Icons.catching_pokemon, color: AppColors.pokeBallRed, size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pokéball',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${_user?.pokeballCount ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.catching_pokemon, size: 80, color: AppColors.greyMedium),
          const SizedBox(height: 16),
          Text(
            'Belum ada Pokémon',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol Gacha untuk mulai!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.greyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _inventory.length,
      itemBuilder: (context, index) {
        final item = _inventory[index];
        return _buildPokemonCard(item);
      },
    );
  }

  Widget _buildPokemonCard(InventoryModel item) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke DetailScreen dengan pokemonId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(pokemonId: item.pokemonId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sprite Pokémon
            CachedNetworkImage(
              imageUrl: item.spriteUrl,
              width: 72,
              height: 72,
              placeholder: (_, url) => const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (_, url, error) => const Icon(
                Icons.catching_pokemon,
                size: 48,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(height: 4),
            // ID Pokémon
            Text(
              '#${item.pokemonId}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
