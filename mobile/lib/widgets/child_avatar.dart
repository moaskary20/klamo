import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/constants/api_constants.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 56,
  });

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiConstants.resolveMediaUrl(imageUrl);
    if (resolvedUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.yellow, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple.withValues(alpha: 0.25),
              blurRadius: 8,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: size / 2,
          backgroundImage: NetworkImage(resolvedUrl),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.orange, AppTheme.pink],
        ),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orange.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first : '?',
        style: TextStyle(
          fontSize: size / 2.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
