import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/child_avatar.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:klamo_mobile/widgets/world_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final child = appState.selectedChild;
    final worlds = appState.worlds;

    return Scaffold(
      appBar: KlamoAppBar(
        title: Text('مرحباً ${child?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: () => context.push('/progress'),
            icon: const Icon(Icons.emoji_events),
            tooltip: 'التقدم',
          ),
          IconButton(
            onPressed: () async {
              await appState.logout();
              if (context.mounted) context.go('/auth');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (child != null)
              PlayfulCard(
                accent: AppTheme.purple,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ChildAvatar(name: child.name, imageUrl: child.avatar),
                  title: Text(
                    '${child.name} • المستوى ${child.level}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'اختر عالماً وابدأ المغامرة! 🚀',
                    style: TextStyle(color: AppTheme.purpleDeep.withValues(alpha: 0.8)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'العوالم التعليمية ✨',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: worlds.length,
                itemBuilder: (context, index) {
                  final world = worlds[index];

                  return WorldCard(
                    name: world.name,
                    imageUrl: world.iconUrl,
                    itemsCount: world.itemsCount,
                    accentGradient: AppTheme.worldGradients[
                      index % AppTheme.worldGradients.length
                    ],
                    onTap: () => context.push('/world/${world.id}', extra: world.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
