import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../services/pokeapi_service.dart';
import '../models/pokemon_detail_model.dart';

/// DetailScreen — menampilkan detail Pokémon dari PokeAPI.
/// Menerima [pokemonId] melalui constructor.
class DetailScreen extends StatelessWidget {
  final int pokemonId;

  const DetailScreen({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonDetailModel>(
      future: PokeapiService().getPokemonDetail(pokemonId),
      builder: (context, snapshot) {
        final appBar = AppBar(
          title: Text(
            'Pokémon #$pokemonId',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: appBar,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

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

        final pokemon = snapshot.data!;
        return Scaffold(
          backgroundColor: _getTypeColor(pokemon.types.first).withOpacity(0.15),
          appBar: appBar,
          body: _DetailContent(pokemon: pokemon),
        );
      },
    );
  }
}

/// Widget konten detail — dipisahkan agar build() tidak terlalu nested.
class _DetailContent extends StatelessWidget {
  final PokemonDetailModel pokemon;

  const _DetailContent({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Sprite ──
          _buildSpriteCard(),
          const SizedBox(height: 20),

          // ── Info Dasar ──
          _buildInfoCard(),
          const SizedBox(height: 16),

          // ── Types ──
          _buildTypesRow(),
          const SizedBox(height: 20),

          // ── Stats ──
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildSpriteCard() {
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
            imageUrl: pokemon.spriteUrl,
            width: 180,
            height: 180,
            placeholder: (_, url) => const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, url, error) => const Icon(
              Icons.catching_pokemon,
              size: 100,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            pokemon.name.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
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

  Widget _buildInfoCard() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoTile(
            icon: Icons.straighten,
            label: 'Tinggi',
            value: '${(pokemon.height / 10).toStringAsFixed(1)} m',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoTile(
            icon: Icons.fitness_center,
            label: 'Berat',
            value: '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoTile(
            icon: Icons.bolt,
            label: 'BST',
            value: '${pokemon.bst}',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pokemon.types.map((type) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _getTypeColor(type),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            type.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsCard() {
    // Urutan stats yang ingin ditampilkan
    const statOrder = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];
    const statLabels = {
      'hp': 'HP',
      'attack': 'Attack',
      'defense': 'Defense',
      'special-attack': 'Sp. Atk',
      'special-defense': 'Sp. Def',
      'speed': 'Speed',
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
            'Base Stats',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...statOrder.map((stat) {
            final value = pokemon.stats[stat] ?? 0;
            final label = statLabels[stat] ?? stat;
            return _buildStatBar(label, value);
          }),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value) {
    // Normalisasi: max base stat biasanya 255
    final ratio = (value / 255).clamp(0.0, 1.0);
    final color = ratio > 0.6
        ? AppColors.success
        : ratio > 0.35
        ? AppColors.gold
        : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 70,
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
              '$value',
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
}

/// Warna berdasarkan tipe Pokémon.
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