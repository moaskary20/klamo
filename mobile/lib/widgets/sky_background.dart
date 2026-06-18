import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class SkyBackground extends StatelessWidget {
  const SkyBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.skyBackground,
      child: Stack(
        children: [
          Positioned(
            top: 40,
            right: 24,
            child: Icon(
              Icons.star_rounded,
              color: AppTheme.yellow.withValues(alpha: 0.75),
              size: 28,
            ),
          ),
          Positioned(
            top: 110,
            left: 36,
            child: Icon(
              Icons.star_rounded,
              color: AppTheme.yellow.withValues(alpha: 0.55),
              size: 20,
            ),
          ),
          Positioned(
            top: 180,
            right: 80,
            child: Icon(
              Icons.star_rounded,
              color: Colors.white.withValues(alpha: 0.45),
              size: 16,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
