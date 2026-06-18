import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/constants/api_constants.dart';
import 'package:klamo_mobile/core/constants/content_assets.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class ItemImage extends StatelessWidget {
  const ItemImage({
    super.key,
    required this.word,
    this.imageUrl,
    this.size = 180,
  });

  final String word;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConstants.resolveMediaUrl(imageUrl);
    final asset = ContentAssets.itemImage(word);

    if (resolvedUrl != null) {
      return _framed(
        child: Image.network(
          resolvedUrl,
          height: size,
          width: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _loading();
          },
          errorBuilder: (_, __, ___) => _assetImage(asset) ?? _placeholder(),
        ),
      );
    }

    final local = _assetImage(asset);
    if (local != null) return local;

    return _placeholder();
  }

  Widget? _assetImage(String? asset) {
    if (asset == null) return null;

    return _framed(
      child: Image.asset(
        asset,
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _framed({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyDeep.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: child,
      ),
    );
  }

  Widget _loading() {
    return SizedBox(
      height: size,
      width: size,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _placeholder() {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.skyLight, AppTheme.orangeWarm],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        word,
        style: TextStyle(
          fontSize: size * 0.18,
          fontWeight: FontWeight.w800,
          color: AppTheme.skyDeep,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
