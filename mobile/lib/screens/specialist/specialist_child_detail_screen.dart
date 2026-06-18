import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/child_avatar.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistChildDetailScreen extends StatelessWidget {
  const SpecialistChildDetailScreen({super.key, required this.childId});

  final int childId;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final child = appState.children.where((c) => c.id == childId).firstOrNull;

    if (child == null) {
      return Scaffold(
        appBar: const KlamoAppBar(title: Text('تفاصيل الطفل')),
        body: const Center(child: Text('الطفل غير موجود')),
      );
    }

    return Scaffold(
      appBar: KlamoAppBar(
        title: Text(child.name),
        actions: [
          IconButton(
            onPressed: () => context.push('/specialist/child/$childId/edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlayfulCard(
            accent: AppTheme.purple,
            child: Row(
              children: [
                ChildAvatar(name: child.name, imageUrl: child.avatar, size: 72),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      Text('المستوى ${child.level} • ${child.age} سنوات'),
                      if (child.parent != null)
                        Text('ولي الأمر: ${child.parent!.name}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _metricCard('نسبة الإنجاز', '${child.completionRate?.toStringAsFixed(1) ?? '—'}%'),
          _metricCard('الأداء العام', '${child.overallPerformanceScore?.toStringAsFixed(1) ?? '—'}%'),
          _metricCard('كلمات مُدرَّب عليها', '${child.trainedWordsCount ?? '—'}'),
          _metricCard('عدد المحاولات', '${child.totalAttemptsCount ?? '—'}'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await appState.selectChild(child);
              if (context.mounted) context.push('/progress');
            },
            icon: const Icon(Icons.emoji_events),
            label: const Text('عرض تقرير التقدم التفصيلي'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, appState, child),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('حذف الطفل', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PlayfulCard(
        accent: AppTheme.teal,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppState appState, ChildModel child) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الطفل'),
        content: Text('هل تريد حذف ${child.name}؟ لا يمكن التراجع.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    await appState.deleteChild(child.id);
    if (context.mounted) context.pop();
  }
}
