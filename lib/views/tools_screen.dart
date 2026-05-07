import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

/// ToolsScreen — ransel/inventory item pengguna (Pokéball, Potion, Berry, dll).
class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _supabaseService = SupabaseService();

  UserModel? _user;
  bool _isLoading = true;

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
      // setState: simpan data user ke state
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Daftar item dalam ransel (Pokéball dari data user, sisanya statis).
  List<_ToolItem> get _toolItems => [
        _ToolItem(
          name: 'Pokéball',
          count: _user?.pokeballCount ?? 0,
          icon: Icons.catching_pokemon,
          color: AppColors.pokeBallRed,
          description: 'Lempar untuk menangkap Pokémon.',
        ),
        _ToolItem(
          name: 'PokéCoin',
          count: _user?.pokecoinBalance ?? 0,
          icon: Icons.monetization_on,
          color: AppColors.gold,
          description: 'Mata uang untuk membeli item.',
        ),
        _ToolItem(
          name: 'Potion',
          count: 0,
          icon: Icons.local_hospital,
          color: const Color(0xFF7C4DFF),
          description: 'Memulihkan HP Pokémon.',
        ),
        _ToolItem(
          name: 'Razz Berry',
          count: 0,
          icon: Icons.eco,
          color: const Color(0xFFE91E63),
          description: 'Meningkatkan peluang tangkap.',
        ),
        _ToolItem(
          name: 'Incense',
          count: 0,
          icon: Icons.local_fire_department,
          color: const Color(0xFFFF6D00),
          description: 'Menarik Pokémon langka.',
        ),
        _ToolItem(
          name: 'Lucky Egg',
          count: 0,
          icon: Icons.egg,
          color: const Color(0xFF00C853),
          description: '2x EXP selama 30 menit.',
        ),
        _ToolItem(
          name: 'Star Piece',
          count: 0,
          icon: Icons.star,
          color: const Color(0xFFFFD600),
          description: '1.5x Stardust selama 30 menit.',
        ),
        _ToolItem(
          name: 'Revive',
          count: 0,
          icon: Icons.favorite,
          color: const Color(0xFF00BCD4),
          description: 'Menghidupkan Pokémon pingsan.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Ransel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemCount: _toolItems.length,
                itemBuilder: (context, index) {
                  return _buildToolCard(_toolItems[index]);
                },
              ),
            ),
    );
  }

  Widget _buildToolCard(_ToolItem item) {
    final isAvailable = item.count > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: isAvailable
            ? Border.all(color: item.color.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: isAvailable ? 0.15 : 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 24,
                color: isAvailable
                    ? item.color
                    : AppColors.greyMedium,
              ),
            ),
            const SizedBox(height: 8),

            // ── Nama ──
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),

            // ── Jumlah ──
            Text(
              'x${item.count}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isAvailable ? item.color : AppColors.greyMedium,
              ),
            ),

            // ── Deskripsi ──
            Flexible(
              child: Text(
                item.description,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model sederhana untuk item di ransel.
class _ToolItem {
  final String name;
  final int count;
  final IconData icon;
  final Color color;
  final String description;

  const _ToolItem({
    required this.name,
    required this.count,
    required this.icon,
    required this.color,
    required this.description,
  });
}
