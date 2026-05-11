import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/constants.dart';
import '../../models/berry_model.dart';
import '../tools_detail_screen.dart';

class BerryTabView extends StatelessWidget {
  final List<BerryModel> berries;
  final bool isGrid;
  final VoidCallback onRefresh;
  final String searchQuery;

  const BerryTabView({
    super.key,
    required this.berries,
    required this.isGrid,
    required this.onRefresh,
    required this.searchQuery,
  });

  void _navigateToDetail(BuildContext context, int berryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ToolsDetailScreen(id: berryId, type: 'berry'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (berries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.greyMedium),
            const SizedBox(height: 16),
            Text(
              'Pencarian "$searchQuery" tidak ditemukan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: isGrid
          ? GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: berries.length,
              itemBuilder: (context, index) {
                final berry = berries[index];
                return GestureDetector(
                  onTap: () => _navigateToDetail(context, berry.id),
                  child: _buildCard(
                    id: berry.id,
                    name: '${berry.name.toUpperCase()} BERRY',
                    imageUrl: berry.spriteUrl,
                    subtitle: '',
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: berries.length,
              itemBuilder: (context, index) {
                final berry = berries[index];
                return GestureDetector(
                  onTap: () => _navigateToDetail(context, berry.id),
                  child: _buildTile(
                    id: berry.id,
                    name: '${berry.name.toUpperCase()} BERRY',
                    imageUrl: berry.spriteUrl,
                    subtitle: '',
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTile({
    required int id,
    required String name,
    required String imageUrl,
    required String subtitle,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 40,
                    height: 40,
                    placeholder: (_, __) => const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.error,
                      size: 40,
                      color: AppColors.greyMedium,
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '#${id.toString().padLeft(3, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          // Arrow indicator
          const Icon(Icons.chevron_right, color: AppColors.greyMedium, size: 20),
        ],
      ),
    );
  }

  Widget _buildCard({
    required int id,
    required String name,
    required String imageUrl,
    required String subtitle,
  }) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 40),
                  )
                : const Icon(Icons.image_not_supported, size: 40),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle.isNotEmpty ? '#${id.toString().padLeft(3, '0')} | $subtitle' : '#${id.toString().padLeft(3, '0')}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
