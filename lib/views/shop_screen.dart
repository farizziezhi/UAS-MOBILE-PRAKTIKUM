import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';
import '../controllers/shop_controller.dart';
import '../models/user_model.dart';

/// ShopScreen — toko pembelian Pokéball dengan PokéCoin.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _supabaseService = SupabaseService();
  final _shopController = ShopController();

  UserModel? _user;
  bool _isLoading = true;
  int? _buyingIndex; // index paket yang sedang diproses

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final user = await _supabaseService.getUserProfile(uid);
      // setState: simpan data user
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBuy(_ShopPackage pkg, int index) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    // setState: tandai paket yang sedang diproses
    setState(() => _buyingIndex = index);

    try {
      await _shopController.buyPokeball(uid, pkg.price, pkg.amount);

      // Refresh data user setelah beli
      final updatedUser = await _supabaseService.getUserProfile(uid);

      if (!mounted) return;

      // setState: update saldo
      setState(() {
        _user = updatedUser;
        _buyingIndex = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Berhasil membeli ${pkg.amount} Pokéball!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // setState: selesai proses (gagal)
      setState(() => _buyingIndex = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Daftar paket pembelian Pokéball.
  static const List<_ShopPackage> _packages = [
    _ShopPackage(
      name: '1 Pokéball',
      amount: 1,
      price: 100,
      icon: Icons.catching_pokemon,
      badge: null,
    ),
    _ShopPackage(
      name: '5 Pokéball',
      amount: 5,
      price: 450,
      icon: Icons.catching_pokemon,
      badge: 'HEMAT 10%',
    ),
    _ShopPackage(
      name: '10 Pokéball',
      amount: 10,
      price: 800,
      icon: Icons.catching_pokemon,
      badge: 'HEMAT 20%',
    ),
    _ShopPackage(
      name: '25 Pokéball',
      amount: 25,
      price: 1750,
      icon: Icons.catching_pokemon,
      badge: 'BEST VALUE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Shop',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Saldo PokéCoin ──
                    _buildCoinBanner(),
                    const SizedBox(height: 20),

                    // ── Katalog ──
                    Text(
                      'Beli Pokéball',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(_packages.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPackageCard(_packages[index], index),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCoinBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.gold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on, color: AppColors.gold, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo PokéCoin',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_user?.pokecoinBalance ?? 0}',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(_ShopPackage pkg, int index) {
    final isBuying = _buyingIndex == index;
    final canAfford = (_user?.pokecoinBalance ?? 0) >= pkg.price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: pkg.badge != null
            ? Border.all(color: AppColors.pokeBallRed.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // ── Icon ──
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.pokeBallRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(pkg.icon, color: AppColors.pokeBallRed, size: 28),
                  if (pkg.amount > 1)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.pokeBallRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'x${pkg.amount}',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        pkg.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (pkg.badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pokeBallRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pkg.badge!,
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${pkg.price}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tombol Beli ──
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: (isBuying || !canAfford) ? null : () => _handleBuy(pkg, index),
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? AppColors.success : AppColors.greyLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: isBuying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      canAfford ? 'Beli' : 'Kurang',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Model paket pembelian Pokéball.
class _ShopPackage {
  final String name;
  final int amount;
  final int price;
  final IconData icon;
  final String? badge;

  const _ShopPackage({
    required this.name,
    required this.amount,
    required this.price,
    required this.icon,
    required this.badge,
  });
}
