import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/constants/content_assets.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class ActivityChip extends StatelessWidget {
  const ActivityChip({
    super.key,
    required this.label,
    required this.type,
    required this.onPressed,
  });

  final String label;
  final String type;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final imageAsset = ContentAssets.activityImage(type);

    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: StadiumBorder(
        side: BorderSide(color: AppTheme.purple.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(imageAsset),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.purpleDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageAsset) {
    if (imageAsset == null) {
      return Icon(_iconForType(type), color: AppTheme.tealDeep, size: 22);
    }

    return ClipOval(
      child: Image.asset(
        imageAsset,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(_iconForType(type), color: AppTheme.tealDeep, size: 22),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'word_recognition' => Icons.menu_book,
      'auditory_discrimination' => Icons.hearing,
      _ => Icons.mic,
    };
  }
}
