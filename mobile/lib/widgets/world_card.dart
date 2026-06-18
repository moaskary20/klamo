import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/constants/api_constants.dart';
import 'package:klamo_mobile/core/constants/content_assets.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class WorldCard extends StatelessWidget {
  const WorldCard({
    super.key,
    required this.name,
    required this.onTap,
    this.itemsCount,
    this.imageAsset,
    this.imageUrl,
    this.accentGradient,
  });

  final String name;
  final VoidCallback onTap;
  final int? itemsCount;
  final String? imageAsset;
  final String? imageUrl;
  final LinearGradient? accentGradient;

  @override
  Widget build(BuildContext context) {
    final asset = imageAsset ?? ContentAssets.worldImage(name);
    final gradient = accentGradient ??
        const LinearGradient(colors: [AppTheme.purpleDeep, AppTheme.tealDeep]);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.skyDeep.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _WorldImage(asset: asset, imageUrl: imageUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gradient.colors.first.withValues(alpha: 0.15),
                      gradient.colors.last.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 8),
                        ],
                      ),
                    ),
                    if (itemsCount != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$itemsCount كلمة',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldImage extends StatelessWidget {
  const _WorldImage({
    required this.asset,
    required this.imageUrl,
  });

  final String? asset;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return Image.asset(
        asset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _networkOrFallback(),
      );
    }

    return _networkOrFallback();
  }

  Widget _networkOrFallback() {
    final resolvedUrl = ApiConstants.resolveMediaUrl(imageUrl);
    if (resolvedUrl != null) {
      return Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _FallbackWorldImage(),
      );
    }

    return const _FallbackWorldImage();
  }
}

class _FallbackWorldImage extends StatelessWidget {
  const _FallbackWorldImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.teal, AppTheme.purple],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.public, color: Colors.white, size: 48),
    );
  }
}
