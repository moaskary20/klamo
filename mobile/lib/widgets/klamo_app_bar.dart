import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';

class KlamoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KlamoAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.flexibleImage,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final String? flexibleImage;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          if (flexibleImage != null)
            Image.asset(
              flexibleImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: flexibleImage == null
                  ? AppTheme.appBarGradient
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
