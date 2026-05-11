import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../services/pokeapi_service.dart';
import '../models/berry_detail_model.dart';
import '../models/item_detail_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Helper: Warna berdasarkan tipe — shared dengan detail_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

Color _getTypeColor(String type) {
  const typeColors = {
    'normal': Color(0xFFA8A878),
    'fire': Color(0xFFF08030),
    'water': Color(0xFF6890F0),
    'grass': Color(0xFF78C850),
    'electric': Color(0xFFF8D030),
    'ice': Color(0xFF98D8D8),
    'fighting': Color(0xFFC03028),
    'poison': Color(0xFFA040A0),
    'ground': Color(0xFFE0C068),
    'flying': Color(0xFFA890F0),
    'psychic': Color(0xFFF85888),
    'bug': Color(0xFFA8B820),
    'rock': Color(0xFFB8A038),
    'ghost': Color(0xFF705898),
    'dragon': Color(0xFF7038F8),
    'dark': Color(0xFF705848),
    'steel': Color(0xFFB8B8D0),
    'fairy': Color(0xFFEE99AC),
  };
  return typeColors[type] ?? AppColors.greyMedium;
}

// ═══════════════════════════════════════════════════════════════════════════
// ToolsDetailScreen — Menampilkan detail Berry ATAU Item dari PokeAPI.
// Menerima [id] dan [type] ('berry' atau 'item') melalui constructor.
// ═══════════════════════════════════════════════════════════════════════════

class ToolsDetailScreen extends StatelessWidget {
  final int id;
  final String type; // 'berry' atau 'item'

  const ToolsDetailScreen({
    super.key,
    required this.id,
    required this.type,
  });

  bool get _isBerry => type == 'berry';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
      future: _isBerry
          ? PokeapiService().getBerryDetail(id)
          : PokeapiService().getItemDetail(id),
      builder: (context, snapshot) {
        final appBar = AppBar(
          title: Text(
            _isBerry ? 'Berry #$id' : 'Item #$id',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        );

        // ── State: Loading ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: appBar,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // ── State: Error ──
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: appBar,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        // ── State: Data Loaded ──
        if (_isBerry) {
          final berry = snapshot.data! as BerryDetailModel;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: appBar,
            body: _BerryDetailContent(berry: berry),
          );
        } else {
          final item = snapshot.data! as ItemDetailModel;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: appBar,
            body: _ItemDetailContent(item: item),
          );
        }
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared Sub-Widgets — dipakai oleh Berry & Item detail
// ═══════════════════════════════════════════════════════════════════════════

/// Card untuk menampilkan sprite & nama
class _SpriteCard extends StatelessWidget {
  final String spriteUrl;
  final String name;
  final int id;
  final IconData fallbackIcon;

  const _SpriteCard({
    required this.spriteUrl,
    required this.name,
    required this.id,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: spriteUrl,
            width: 180,
            height: 180,
            placeholder: (_, url) => const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, url, error) =>
                Icon(fallbackIcon, size: 100, color: AppColors.greyMedium),
          ),
          const SizedBox(height: 12),
          Text(
            name.replaceAll('-', ' ').toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '#${id.toString().padLeft(3, '0')}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile kecil untuk info (angka + label)
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.pokeBallRed, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card untuk menampilkan deskripsi efek
class _EffectCard extends StatelessWidget {
  final String title;
  final String description;

  const _EffectCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Berry Detail Content
// ═══════════════════════════════════════════════════════════════════════════

class _BerryDetailContent extends StatelessWidget {
  final BerryDetailModel berry;

  const _BerryDetailContent({required this.berry});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Sprite ──
          _SpriteCard(
            spriteUrl: berry.spriteUrl,
            name: berry.name,
            id: berry.id,
            fallbackIcon: Icons.eco,
          ),
          const SizedBox(height: 20),

          // ── Info Dasar: Ukuran, Pertumbuhan, Harga ──
          _buildBerryInfoRow(),
          const SizedBox(height: 16),

          // ── Flavor Chips ──
          _buildFlavorChips(),
          const SizedBox(height: 20),

          // ── Effect Card ──
          _EffectCard(
            title: 'Efek',
            description:
                berry.effectDescription ?? 'Deskripsi efek tidak tersedia',
          ),
          const SizedBox(height: 20),

          // ── Flavor Potency Bars ──
          _buildFlavorBarsCard(),
        ],
      ),
    );
  }

  Widget _buildBerryInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.straighten,
            label: 'Ukuran',
            value: '${berry.size} mm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.schedule,
            label: 'Pertumbuhan',
            value: '${berry.growthTime}h',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.shopping_bag,
            label: 'Harga',
            value: '\$${berry.cost}',
          ),
        ),
      ],
    );
  }

  Widget _buildFlavorChips() {
    // Filter rasa dengan potency > 0
    final activeFlavors =
        berry.flavors.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activeFlavors.map((flavor) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getFlavorColor(flavor.key),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${flavor.key.toUpperCase()} (${flavor.value})',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFlavorBarsCard() {
    const flavorOrder = ['spicy', 'dry', 'sweet', 'bitter', 'sour'];
    const flavorLabels = {
      'spicy': 'Pedas',
      'dry': 'Kering',
      'sweet': 'Manis',
      'bitter': 'Pahit',
      'sour': 'Asam',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Rasa',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...flavorOrder.map((flavor) {
            final potency = berry.flavors[flavor] ?? 0;
            final label = flavorLabels[flavor] ?? flavor;
            return _buildFlavorBar(label, potency, flavor);
          }),
        ],
      ),
    );
  }

  Widget _buildFlavorBar(String label, int potency, String flavorType) {
    final ratio = (potency / 100).clamp(0.0, 1.0);
    final color = _getFlavorColor(flavorType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$potency',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: AppColors.greyLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Warna berdasarkan rasa Berry
  Color _getFlavorColor(String flavor) {
    const flavorColors = {
      'spicy': Color(0xFFF08030),
      'dry': Color(0xFFA8A878),
      'sweet': Color(0xFFEE99AC),
      'bitter': Color(0xFF8B5CF6),
      'sour': Color(0xFFFFC000),
    };
    return flavorColors[flavor] ?? AppColors.greyMedium;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Item Detail Content
// ═══════════════════════════════════════════════════════════════════════════

class _ItemDetailContent extends StatelessWidget {
  final ItemDetailModel item;

  const _ItemDetailContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Sprite ──
          _SpriteCard(
            spriteUrl: item.spriteUrl,
            name: item.name,
            id: item.id,
            fallbackIcon: Icons.catching_pokemon,
          ),
          const SizedBox(height: 20),

          // ── Info Dasar: Harga, Kategori, Fling Power ──
          _buildItemInfoRow(),
          const SizedBox(height: 16),

          // ── Attribute Chips ──
          _buildAttributeChips(),
          const SizedBox(height: 20),

          // ── Effect Card (Mechanical Effect) ──
          _EffectCard(
            title: 'Efek Mekanis',
            description:
                item.effectDescription ?? 'Deskripsi efek tidak tersedia',
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfoRow() {
    // Format kategori: ganti '-' dengan spasi, capitalize
    final categoryLabel = item.category
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');

    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.monetization_on,
            label: 'Harga',
            value: '\$${item.cost}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.category,
            label: 'Kategori',
            value: categoryLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.flash_on,
            label: 'Fling Power',
            value: '${item.flingPower}',
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeChips() {
    if (item.attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: item.attributes.map((attr) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getAttributeColor(attr),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                attr.replaceAll('-', ' ').toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Warna berdasarkan atribut item
  Color _getAttributeColor(String attribute) {
    const attributeColors = {
      'countable': Color(0xFF3B82F6),
      'consumable': Color(0xFFEF4444),
      'usable-overworld': Color(0xFF22C55E),
      'usable-in-battle': Color(0xFFF08030),
      'holdable': Color(0xFF8B5CF6),
      'holdable-passive': Color(0xFF6366F1),
      'holdable-active': Color(0xFF7C3AED),
      'underground': Color(0xFFA16207),
    };
    return attributeColors[attribute] ?? AppColors.greyMedium;
  }
}
