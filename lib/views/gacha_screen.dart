import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../controllers/gacha_controller.dart';
import '../models/pokemon_model.dart';

/// GachaScreen — layar gacha dengan animasi Pokéball.
class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen>
    with SingleTickerProviderStateMixin {
  final _gachaController = GachaController();

  bool _isRolling = false;
  late AnimationController _animController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleGacha() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    // setState: mulai animasi rolling
    setState(() => _isRolling = true);
    _animController.repeat(reverse: true);

    try {
      // Tunggu sebentar agar animasi terasa
      await Future.delayed(const Duration(milliseconds: 1500));

      final result = await _gachaController.rollGacha(uid);

      _animController.stop();
      _animController.reset();

      if (!mounted) return;

      // setState: selesai rolling
      setState(() => _isRolling = false);

      // Tampilkan dialog hasil gacha
      _showResultDialog(result);
    } catch (e) {
      _animController.stop();
      _animController.reset();

      if (!mounted) return;

      // setState: selesai rolling (error)
      setState(() => _isRolling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final pokemon = result['pokemon'] as PokemonModel;
    final isDuplicate = result['isDuplicate'] as bool;
    final coinReward = result['coinReward'] as int;
    final newBallCount = result['newBallCount'] as int;
    final newCoinBalance = result['newCoinBalance'] as int;

    // Warna border sesuai rarity
    Color rarityColor;
    switch (pokemon.rarity) {
      case 'legendary':
        rarityColor = AppColors.legendary;
        break;
      case 'epic':
        rarityColor = AppColors.epic;
        break;
      case 'rare':
        rarityColor = AppColors.rare;
        break;
      default:
        rarityColor = AppColors.common;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: rarityColor, width: 3),
        ),
        title: Text(
          isDuplicate ? '🔄 Duplikat!' : '🎉 Pokémon Baru!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sprite
            CachedNetworkImage(
              imageUrl: pokemon.spriteUrl,
              width: 120,
              height: 120,
              placeholder: (_, url) =>
                  const CircularProgressIndicator(strokeWidth: 2),
              errorWidget: (_, url, error) => const Icon(
                Icons.catching_pokemon,
                size: 80,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Nama
            Text(
              pokemon.name.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            // Rarity badge
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pokemon.rarity.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info duplikat atau baru
            if (isDuplicate) ...[
              Text(
                'Pokémon sudah ada di koleksi.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '+$coinReward PokéCoin',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ] else
              Text(
                'Ditambahkan ke koleksi!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Saldo terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat(
                    Icons.monetization_on, '$newCoinBalance', AppColors.gold),
                _buildMiniStat(Icons.catching_pokemon, '$newBallCount',
                    AppColors.pokeBallRed),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pokeBallRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gacha',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRolling ? 'Melempar Pokéball...' : 'Tekan Pokéball!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 40),

            // ── Pokéball (animasi goyang saat rolling) ──
            GestureDetector(
              onTap: _isRolling ? null : _handleGacha,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _isRolling ? _shakeAnimation.value : 0,
                    child: child,
                  );
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pokeBallRed.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 120,
                    color: _isRolling
                        ? AppColors.gold
                        : AppColors.pokeBallRed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            Text(
              _isRolling ? '🎲 Rolling...' : 'Tap untuk gacha 1x',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
