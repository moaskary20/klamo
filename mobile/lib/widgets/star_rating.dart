import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 5,
    this.size = 32,
  });

  final int stars;
  final int maxStars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Icon(
          index < stars ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppTheme.yellow,
          size: size,
          shadows: index < stars
              ? const [
                  Shadow(color: AppTheme.orange, blurRadius: 6),
                ]
              : null,
        );
      }),
    );
  }
}
