import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/core/constants/content_assets.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/activity_chip.dart';
import 'package:klamo_mobile/widgets/item_image.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({
    super.key,
    required this.worldId,
    required this.worldName,
  });

  final int worldId;
  final String worldName;

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late Future<List<ItemModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = context.read<AppState>().loadWorldItems(widget.worldId);
  }

  void _openActivity(ActivityModel activity) {
    switch (activity.type) {
      case 'word_recognition':
        context.push('/activity/word/${activity.id}');
      case 'auditory_discrimination':
        context.push('/activity/auditory/${activity.id}');
      case 'pronunciation_recording':
        context.push('/activity/pronunciation/${activity.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final worldImage = ContentAssets.worldImage(widget.worldName);

    return Scaffold(
      appBar: KlamoAppBar(
        title: Text(widget.worldName),
        flexibleImage: worldImage,
      ),
      body: FutureBuilder<List<ItemModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('لا توجد كلمات متاحة في هذا المستوى'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return PlayfulCard(
                accent: AppTheme.teal,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ItemImage(
                            word: item.wordName,
                            imageUrl: item.imageUrl,
                            size: 88,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.wordName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'اختر نشاطاً للتعلّم',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.purpleDeep.withValues(alpha: 0.75),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.activities.map((activity) {
                          return ActivityChip(
                            label: activity.typeLabel,
                            type: activity.type,
                            onPressed: () => _openActivity(activity),
                          );
                        }).toList(),
                      ),
                    ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
