import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class PlayfulCard extends StatelessWidget {
  const PlayfulCard({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.playfulCardDecoration(accent: accent),
      padding: padding,
      child: child,
    );
  }
}
